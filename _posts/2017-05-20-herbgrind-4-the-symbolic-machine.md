---
layout: post
title: "Herbgrind Part 4: The Symbolic Machine"
author: Alex Sanchez-Stern
---

Welcome back to my series of posts on Herbgrind, a dynamic analysis
tool that finds floating point issues in compiled programs. The
purpose of this series is to explain how Herbgrind works and the
principles behind its design. To do that, we're starting with a
simple hypothetical computer called the "Float Machine", which is just
enough to capture the interesting floating point behavior of a real
computer, like the one that's probably sitting on your desk.

![Herbgrind logo]({{ site.baseurl }}/images/full-logo.png){:style="width:30%" class="centered"}

In
the
[beginning of the series]({{ site.baseurl }}/2017/04/27/herbgrind-1-the-float-machine.html) I
described the basics of the float machine. Then, we extended it with a
"Real" machine for figuring out the correct output of the program. In
the
[previous post]({{ site.baseurl}}/2017/05/07/herbgrind-3-the-local-machine.html),
I showed how we can "localize" errors to a particular operation to
find the source of error.

The only problem is, one operation alone can't explain the true cause
of floating point error. Each operation on its own is about as
accurate as it can be in IEEE754 floating point. It's only when
operations compose that non-trivial error starts to appear. So while
the Localizing Machine is good for figuring out where the error first
appears, it doesn't tell the whole story.

You can see this in this simple example:

$$(x + 1) - x$$

As I mentioned in earlier posts, this computation should always return
$$1$$, but for large values of $$x$$ it returns $$0$$ instead. This is
because floating point can only represent numbers accurately at one
magnitude at a time. So when you add the small value $$1$$ to a large
value of $$x$$, it gets rounded off, and you just get $$x$$. But this
isn't bad floating point error yet, because that's still the closest
floating point number to the correct answer, so it's as "correct" as
it can be. However, once you subtract $$x$$ back out, you get $$0$$
instead of $$1$$, and that's *not* the most correct answer.

Pointing the Localizing Machine at this thing will tell you that the
subtraction is the problem. After all, this is where the value first
becomes different from the closest floating point number to the
correct answer. But the subtraction alone isn't enough to express the
problem: given the inputs $$x$$ and $$x$$, zero is the correct
answer. It's only because we know that the first $$x$$ is wrong in a
very specific way that we know that the subtraction causes a problem.

In general, to figure out enough about the error to fix it, you also
need to look at the operations that come before the error appears.

One way to do this is to just look at the source code. Once you know
where the error appears, you sometimes only need to look a few lines
back to see the relevant operations. Unfortunately this isn't always
the case. Sometimes the operations that matter are scattered across
the program, in different functions and even different modules.

The final machine that makes up Herbgrind is called the Symbolic
Machine, and is intended to bring together the computation that
produced a value so that it can be reported to the user. This way when
you find local error, you'll also know how that value was computed,
and therefore which operations need to be fixed to solve the problem.

How the Symbolic Machine Works
------------------------------

Given the above example, what we want the symbolic machine to do is
produce the expression "$$\texttt{(x + 1) - x}$$". Since the addition and
subtraction could be in different modules though, we can't trust the
code to easily tell us this. Instead, we rely on the *values* in the
program to tell us how they were built.

The Symbolic Machine takes programs, and runs them
"symbolically". When the float machine sees a program that computes $$
1 + 2 $$, it produces $$3$$. But when the symbolic machine sees that
same program, it produces an object representing the computation
abstractly, in this case "$$\texttt{1 + 2}$$".

This is especially powerful when the values flow through the program
in interesting ways. Even if this $$3$$ gets passed around in the
program, and put in a hash table by one piece of code and taken out by
another, it still has the "symbolic" value "$$\texttt{1 + 2}$$". Then,
if someone adds $$4$$ to that $$3$$, it'll produce the expression
"$$\texttt{(1 + 2) + 4}$$", while the client program produces $$7$$.

So the Symbolic Machine has "symbolic memory" which it uses to track
the float memory in the Float Machine. It also has a symbolic
processor which looks at each operation in the program, and does the
correct "symbolic" operation.

This dynamic approach to finding expressions means that we will never
miss part of the computation, because branches and crazy control flow
don't present a problem. Unfortunately it makes it harder for us to
find some information about the program that would be obvious in
source code, like which values are a constant and which values are a
variable. Luckily, we have a few tricks up our sleeves to get that
information back.

Constant or Variable?
---------------------

When we're trying to improve a computation, it's usually pretty
important to know which values are "variables" and which values are
"constants". You can do a lot more transformation of the expression
when you know that a particular value is going to be always the same
value. But try those transformations on a value that changes, and
you'll be in for a bad time!

Unfortunately, as long as we're being completely dynamic, it's nearly
impossible to figure out which is which perfectly. However, some good
guesses can go a long way. For instance: most parts of the program
that are standalone "procedures" with "inputs" that make variables,
are going to be run more than once. When this happens, the symbolic
machine will see the same code fragment run with some of its values
different (the variables), and some the same (the constants).

While so far we've only been talking about traces of values, that is
the history that a particular value went through, now we care about
something else: "code fragments". This is a semi-static (the opposite
of dynamic) notion, so it's worth considering how the two mix. While
with our "dynamic" techniques we stored information at each value, now
we want to also know something about procedures that are run more than
once, so we're going to consider a different kind of storage. We'll
add another kind of memory to our symbolic machine. But instead of
this one having one memory location for each location in the Float
Machine's float memory, it'll have one memory location for every
*program instruction*.

This new program-based memory will store, for each operation in the
program, every trace that was produced at it. Therefore, when we
evaluate $$(1 + 2) + 3$$, we won't just store $$"\texttt{(1 + 2) +
3}"$$ in the symbolic memory where the value $$3$$ goes in float
memory, we'll also store it as one of the traces cooresponding to the
$$+$$ operation.

With each operation holding a set of traces, we can start to infer
which values are constant, and which ones vary. Whenever two traces
disagree on a value, or even a whole branch of the tree, we'll call
that part a variable. And anything that doesn't change between traces
we'll call a constant.

For example, let's say we see a $$+$$ operation with the traces:

$$
\begin{align}
\texttt{1 +}&\texttt{ 4} \\
\texttt{1 +}&\texttt{ 3} \\
\texttt{1 +}&\texttt{ (2 + 5)}\\
\end{align}
$$

Since the 1 on the left hand side of the plus always stays the same,
we'll say it's a constant. Since the right hand side changes, and is
even sometimes another operation, we'll call it a variable. The
resulting inferred expression is:

$$\texttt{1 + x}$$.

In practice finding this solution algorithmically can be a bit tricky,
but we'll discuss this when we talk about bringing Herbgrind to a real
machine, not the abstract Float Machine.

Variable Matching
-----------------

In the previous example we gave the variable the name "$$x$$". We
could have given it a different name, like "$$y$$" or "$$cow$$", but
"$$x$$" is as good a name as any. When there's only one variable, the
name we give it doesn't matter. When multiple variables enter the
picture though, we have to be a little more careful, because we can
have different variables that have the same name, and that means
something special.

For example, in the expression:

$$ (x + 1) - x $$

We have the same variable, $$x$$, in two places. Rather than these
both being independent variables, this means that they can vary in
value, but they are always the same as each other. They could both be
$$10000000$$, or they could both be $$3.5$$, but they have to match.

To reproduce this equation with our dynamic system, we'll need to
figure out which variables are actually the *same* variable. Once
again, we'll look at the traces to determine this. To find out whether
a value was a constant, we would see if it never changed across all
the traces. Similarly, to find out whether two parts of the traces are
actually the same variable, we'll see if their values match across all
traces.

For instance, if we see the traces:

$$
\begin{align}
\texttt{(1 + 2) - 1} \\
\texttt{(2 + 2) - 2} \\
\texttt{(3 + 4) - 3} \\
\end{align}
$$

We'll produce the expression:

$$
\texttt{(x + y) - x}
$$

In this expression, the left side of the $$+$$, and the right side of
the $$-$$ are given the same variable name, $$x$$. The right side of
the $$+$$ is given a different variable name, $$y$$. This is because,
while the first and third number vary across traces, in every trace
they have the same value as each other; in the first they are both
$$1$$, in the second they are both $$2$$, and in the third they are
both $$3$$.

Even though in the second trace the second number matches the other,
we don't give it the same name. Because it differs in the other
traces, we consider it a different variable. Herbgrind only treats two
variables as the same if they match in **every** trace.

The Rules of the Game
---------------------

To make this process of inferring operation trees more concrete, let's
give it a name, and some rules. We'll call this "generalizing the
traces" into a "symbolic expression". *Symbolic*, because while the
traces just involve numbers and operations, when we generalize them we
get variables also, which are "symbols" representing more than one
value.

The rules of this process are all about not being too specific, and
not being too general. If the expression is too specific, then it
won't properly be able to represent the different traces. If it's too
general, than it won't give you enough information.

What does it mean to be too specific? Well, a variable like $$x$$,
$$y$$, or $$cow$$, can represent anything. A number, an operation,
whatever. A variable by itself is never too specific. On the opposite
end, an operation, or a constant, represents only a single thing:
either running that operation, or that constant. We're also going to
do something kind of weird here, and say that an operation on
constants can be "represented" by its result. For instance, the trace:

$$
\texttt{(1 + 2) - 3}
$$

can be represented as "$$\texttt{(1 + 2) - 3}$$", or "$$\texttt{(x +
y) - z}$$", or "$$\texttt{3 - 3}$$", or "$$\texttt{0}$$", or even
"$$\texttt{x}$$". That's a lot of options! If instead we had two
traces:

$$
\begin{align}
\texttt{(1 + 2) - 3}\\
\texttt{(1 + 2) - 4}
\end{align}
$$

Then we wouldn't be able to use "$$\texttt{(1 + 2) - 3}$$",
"$$\texttt{3 - 3}$$", or "$$\texttt{0}$$", because they are now *too
specific*; they don't encompass all of the traces they are supposed to
represent. But we could still use "$$\texttt{(1 + 2) - z}$$",
"$$\texttt{(x + y) - z}$$", "$$\texttt{3 - x}$$", or "$$\texttt{x}$$".

With so many options, we need to figure out which one is best. The
easiest one to pick is always $$x$$, because it can represent
anything. However, it doesn't tell the user very much, and it's not
useful for rewriting the code to be more accurate. The more specific
of a trace we can give, the more chance we have of helping the
user. So we'll always look for the *most specific* trace that is still
*general enough* to represent all the traces that we care about.

In the case of:

$$
\begin{align}
\texttt{(1 + 2) - 3} \\
\texttt{(1 + 2) - 4}
\end{align}
$$

the most specific trace that is general enough is:

$$
\texttt{(1 + 2) - x}
$$

Because in both traces the left hand side of the subtraction is
"$$\texttt{(1 + 2)}$$", it's not too specific to use that for the
generalized symbolic expression. And, it's the most specific trace
possible, since it's completely concrete (just numbers and operations)
and doesn't pre-compute any operations.

On the right hand side of the subtraction, we have a variable $$x$$,
because the value in that position is different in the two different
traces. We couldn't make it a concrete value like $$3$$ or $$4$$,
because that would be *too* specific, and wouldn't represent both
traces.

-------------------------------

Wooh, okay. That's the Symbolic Machine, the last machine in
Herbgrind. Now that we've got all the machines in one place, we can do
some pretty cool things. We can find that there is error in the output
of a program, track it down to a particular part of the computation,
and represent that computation as a symbolic expression to the
user. From there, it's up to the user to fix the computation, and put
the fixed version back in the program.

What we've defined up until now has been on an abstract machine,
called the Float Machine. While the Float Machine has many of the
things a normal computer does, there are still a few differences that
make implementing Herbgrind a bit tricky. In future posts, I'll talk
about these differences, and what Herbgrind does to work on normal
computers.

Still though, what we've defined so far is most of the work. I hope
it's been useful to anyone out there trying to track down and
understand floating point error!
