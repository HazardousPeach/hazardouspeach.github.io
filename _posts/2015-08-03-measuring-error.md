---
layout: post
title: Measuring The Error of Floating Point Programs
author: Alex Sanchez-Stern
---

Hey guys. I'm Alex Sanchez-Stern, and I work at the University of
Washington, in the Programming Languages and Software Engineering
group. For the past year and a half, I've been working on a project
called [Herbie](http://herbie.uwplse.org).

Herbie is a tool to help programmers write fast, accurate numerical
code using floating point numbers.  You see, programmers often want to
reason using the real numbers, but only have finite precision
representations. The IEEE floating point numbers were created so that
programmers could approximate the reals in finite precision. Support
for these floating point numbers is ubiquitous in modern programming
languages.

But the floats provided by the hardware don't always behave like real
numbers, the way many programmers expect. While single small
operations tend to be fairly accurate because of IEEE floating point's
design, once you start composing your operations into more complex
expressions, your output can become arbitrarily far from the same
computation on the real numbers.

That's where Herbie comes in. Herbie is a tool to automatically
improve the accuracy of floating point expressions. Herbie takes a
math expression over the real numbers, and searches for the floating
point program which most accurately computes it. Instead of spending
painstaking hours wrestling with the complex floating point semantics,
or making your code hundreds of times slower by using software
floating point with thousands of bits, you can just enter your formula
in Herbie, and get fast, accurate code to compute it.

Herbie was recently
[published at PLDI](http://herbie.uwplse.org/pldi15.html) (and won
distinguished paper), but it's still limited in some key ways. The
biggest is that Herbie as published is limited to floating point
expressions. This means straight-line code with no control flow
computing a single value. While many of the floating point accuracy
issues you'll run across are essentially issues with the types of
floating point expressions that Herbie deals with, there is still lots
of code out there that needs more complex floating point code, and
needs it to be accurate.

So my team at the UW has decided to next tackle bringing the automated
improvement of Herbie to program fragments containing loops which do
floating point computation. Our research in this area is still very
much exploratory, but the possibilities of applying the automated
search of Herbie to looping program fragments are looking promising.

For the rest of this post (and probably the next few), I'll be writing
about our first forays into improving the accuracy of floating point
program fragments with loops. A lot has already been written on Herbie
and improving the accuracy of straight-line floating point
expressions, and you can read all about it in our
[paper](http://herbie.uwplse.org/pldi15-paper.pdf), on the
[website](http://herbie.uwplse.org/), and on the blog of my friend and
colleague, [Pavel Panchekha](https://pavpanchekha.com/), who has spent
a lot of time and effort explaining some of the interesting problems
we ran into while developing Herbie, and solutions we came up
with. Here, I want to talk about our developing techniques for
improving the accuracy of program fragments with loops.

Measuring Accuracy for Floating Point Expressions
-------------------------------------------------

So let's dive right in. When trying to search for the "best" fragment
for any particular purpose, the first thing we need to do is define
what we mean by "best". So when we're writing a tool to search for the
most accurate version of a fragment, we need to figure out what we
mean by accurate. The intuitive notion is pretty simple: we want a
fragment which is as close as possible to the "right" way of computing
whatever we're computing. Since we're dealing with numbers here, we're
going to assume that the "right" way of evaluating these fragments is
using "real number semantics". Here, "semantics" refers to a
particular way of evaluating a program or expression. So, evaluating
these fragments using "real number semantics" means evaluating them as
if the numbers are pure mathematical real numbers.

Okay, so we know what we mean by "accurate". We are looking to find
expressions where the output when computed using floating point
numbers is as close as possible to the output of the original when
computed using real numbers. But how do we measure this? Our approach
with Herbie has been to settle for an approximation: we pick some
number of random inputs, say 1000, evenly distributed across the
floating point numbers, and we test the accuracy on each one. Then, we
average the results. Even measuring the accuracy of the expression on
a single input, though, is a little trickier than it seems.

Let's go back to our definition of accuracy: the difference between
what the expression's output is when using floats, and what it would
be if we could use the real numbers. For any given input, it's fairly
straightforward to find the the output of the expressions using
floats. We can simply evaluate the expression on that input, using the
hardware's float support. But how do we find the output of the
expression when using real numbers? We can't directly compute using
the real numbers, like we can with the floats. But what we can do is
use software floating point libraries, like [GNU MPFR](www.mpfr.org/),
to compute the answer using more bits than the 32, 64, and sometimes
80 provided by the hardware.

With MPFR we can, at the cost of a 100x-1000x slowdown, compute the
expression using as many bits as we want. And, as the number of bits
reaches infinity, in most cases we will eventually get the exact real
number answer (there are some programs for which this is not the case,
but we're not going to worry about those). We don't really care about
the exact real number answer anyway, because we're not working with
real numbers, we're working with floats. What we actually want is the
float which is closest to the real number answer. So what we really
care about is getting some number out of MPFR such that the first 64
bits are correct.

We're still faced with the question of how many bits to use to compute
the "real" answer, but here we chose to use a heuristic (a heuristic
is basically just an "educated guessing" procedure). We start with a
relatively small number of bits (say, 80), and evaluate the expression
on all of our sampled points using this number of bits. Then we
increase the number of bits, to say 200, and recompute on all the
inputs. Then, if any of the answers we got with 200 bits are different
from the ones we got with 80 bits, we increase the precision again,
and repeat. We keep increasing the number of bits we compute with
until not a single output changes. By this time we've usually reached
a few thousand bits of precision, and can be fairly confident that the
output's that we are testing against as the "ground truth" are
accurate to the real number computation.

So there you have it. To find the error of a floating point
expression, we just sample many input points, compute their outputs
using floats, and then again using MPFR to approximate real number
behavior, and then compare the results. We average these differences
to measure approximately how accurate the expression is. My friend
Pavel Panchekha also has written a bit on using MPFR to find exact
results, you can read his explanation
[here](https://pavpanchekha.com/blog/arbitrary-precision.html).

Measuring Accuracy for Floating Point *Fragments*
----------------------------------------------

This method of measuring error has served us very well in Herbie, and
it works really well when all we want to measure is the error of a
floating point expression. But this sampling technique requires
running the program many times. This wasn't a problem when we were
only looking at straight line code which was quick to evaluate
end-to-end, but now that we're looking at program fragments with
loops, this is in many cases too slow.

Before we get into the details, let's step back and take a look at how
we're representing looping program fragments. The way we'll find loops
represented in a lot of real world code is something like this:

~~~ c
double sum = 0.0;
for(int i = 0; i < length(input_list); i++){
  sum += input_list[i];
}
~~~

For our purposes this will be a bit hard to work with, so we've
simplified it into an s-expression syntax. Although it might not be as
comforting to look at when you're not used to it, it's a lot easier to
manipulate during search.

~~~ lisp
(do-list ;; This bit of syntax indicates that we're going to be looping
         ;; across items in a list (or lists).
  ([sum 0.0 (+ item s)]) ;; This has our loop variables, with their
                         ;; initial values, and their update rules. In
                         ;; this case we have a single variable, sum,
                         ;; which starts at zero, and get's added to
                         ;; item every step.
  ([item lst]) ;; This is what we're looping across. Here it says that
               ;; we're looping for every item in the list lst.
~~~

Since this whole bit of syntax is just an s-expression we can think of
loops just like expressions, and manipulate them more easily.

Okay, now that that's out of the way, let's get to it. Say we're
running on the fragment above, that takes a list of numbers and sums
them up. And let's say that when this fragment is running in the real
world, it will have lists that are around one million items long. If
we have to run this fragment on million item lists every time we take
a step and want to test a new candidate, we're going to be waiting a
long time for our search to finish.

What we'd like to be able to do is run the fragment on much smaller
lists, say those with a hundred items, and use those faster runs to
infer something about how the fragment will behave when it's given
million item lists. In this simple case, where all we want to do is
find the sum of a list of numbers, the fragment with the most accuracy
in summing a hundred item list is probably also the most accurate at
summing a million item list, so all we really need to do is run the
fragment to completion as before, but only pass it short
lists. Unfortunately we don't know that all of the fragments we run on
will behave like this.

For now, let's make a pretty big simplifying assumption, and assume
that the error behavior of the looping program fragments we care about
are generally roughly linear. This means that there is some constant
amount of error that happens regardless of how many iterations we loop
for, and each iteration adds some constant amount of error to the
final answer [^assumption].

[^assumption]: Since we need only a rough, cheap heuristic to guide
    our search, this assumption will work for now. But as we start
    expanding to look at more fragments, this assumption will probably be
    one of the first to go.

So what is our new notion of error? There's a lot of things we could
pick here. End to end error of smaller inputs is still not a bad
choice, but we'll probably be served better in the long run if we pick
something that scales up to bigger inputs well. With a linear model of
error, the choice is fairly simple: we score each fragment during our
search by the *slope* of its error, that is, the best linear fit to
how its error grows.

Now that we have a good notion of what it is we want to measure to get
a handle on the accuracy of a floating point program fragment, how do
we actually measure it? We'll want to get the error of the fragment at
various points in its execution. That means finding the error of the
fragment after zero iterations, after one iteration, after two
iterations, and so on. For our fragment that sums a list, this
translates to the error of summing an empty list, the error of summing
a one-item list, the error of summing a two item list, and so on. To
generalize this notion, we'd like to be able to partially run
fragments, stopping them after a certain number of loop iterations,
and get their error.

Here we start to see the subtleties emerging. How do we partially run
a fragment? How do we assess the error of a partially run fragment? How
will we aggregate these partial results into the slope score that
we're looking for? Let's answer these questions one at a time.

### Partially Running Fragments

Partially running a fragment is in some ways the simplest of these
questions to answer. In our previous work with expressions, we've been
looking at expressions from a big-step semantics point of view. This
means that we define what the expressions eventually evaluate to in a
single, "big", step. But now we want to reason about partially
evaluated fragments, so we need to consider our fragments in
a "smaller" step semantics. To avoid reinventing the wheel in many
places, we're going to try to make our new semantics as similar to our
old ones as possible.

To do this, we'll define two operations on our fragments: a "step"
operation, and a "take value" operation. The former will move the
program fragment forward by one step, roughly a single loop iteration,
and the latter will get the current output of the program, if we were
to stop it without iterating any further. The "take value" will be
pretty simple for the expressions we already know and love: taking the
value of some fragment or sub-expression that doesn't contain loops is
just like evaluating it like we did before; you evaluate the
sub-expressions or sub-fragments, and then apply the top-level
operation to the results. Taking the value of a program fragment with
loops is a little trickier: we don't want to actually evaluate the
loop, because that would mean stepping it, and wouldn't portray its
error in the intermediary step. So instead, we want to use the current
values of the loop variables to get some sort of answer out of the
partially evaluated fragment. But what should this answer be? In the
sum-of-a-list example we looked at above, there's only one meaningful
loop variable, so it makes sense to pick that one as the answer. But
what about loops that have multiple variables?  To answer this, let's
look at the basic structure of looping segments.

The loops that we're going to be looking at here eventually return a
single value, so they can be broken down into four "parts" in a
sense. There are some variables with initial values at the start of
the loop. There are update rules which choose new values for the
variables based on the old values. There is the loop condition, which
tells us when to stop looping. And there's a *return expression*,
which takes the final values of all the variables, and computes the
final answer for the loop. It's this return expression which will
provide us with a way to get a value from partially evaluated loops.

Overall, taking a value of a fragment consists of two procedures, one
for the sub-fragment which are just plain old expressions (possibly
containing looping fragments), and one for those that are
loops. Taking a value of an expression is just evaluating it with our
normal semantics; that is, taking the value of each sub-expression or
sub-fragment, and then applying the expression's operation to
them. Taking the value of a loop is taking the current value of the
loop variables, and evaluating the return expression with them.

Okay, so that's how we take current values, but how do we step the
fragment, so that we can get the values as the fragment progresses?
For expressions with no loops, stepping doesn't really make any sense;
they already have the only value they're ever going to have. We'll say
this means that expressions without loops *can't step*. We'll see what
this means in more detail in a minute.

For a loop, stepping is pretty straightforward. If the loop condition
is true, We just take all the loop variables, and update them using
their updater expressions. Then, we set their initial values in the
loop to their new, updated values. If the loop condition is false,
then the loop will just step to its return expression, with the
current values of all the loop variables substituted in. And that's
it, the loop is one step forward.

It's a little trickier when we think about expressions of loops. For
instance, say you have two lists, and want to sum them independently,
and then sum the results. What you have is an expression, addition,
which operates on two loops. Now what happens when you step this? This
is where the notion of *can't step* will really come into play.The
expression itself cannot step, but the loops can. What we'll do when
we run into expressions like this, where the top level is not a loop
but some sub-expression can step, is we'll step each sub-expression
that can step. This way, the expression will keep stepping until the
loops terminate, and then will turn into a normal expression, and will
stop stepping.

So that's it. Using those procedures, we can both step a fragment, and
take its value at any particular step. We also know when a fragment
stops being able to step, so we have a natural stopping point for
measuring its error. Next, let's look at how we'll actually use these
two operations to find the error of a fragment as it steps.

### Assessing the Error of Partially Run Program Fragments

Okay, so we want to know what the error of a fragment is at each step
of its execution. And we know how to step fragments, and take their
current values. We also know the error is the difference between an
exact evaluation of the fragment, and a floating point evaluation. To
find the error at each step, we'll want to get to that step, and then
be able to take the values of both a floating point evaluation of the
fragment and an exact one.

So here's how we tackle this: Start with two versions of the fragment,
one using floating point, and one using exact evaluation. Take the
values of each version using the procedure above, and compare them to
find the error at step 0. Then, step each version, stepping the
floating point one with floating point semantics, and the exact one
with exact semantics. Then take the error again to get the error at
step 1. Then step, and take the error, and keep repeating until the
fragment can no longer step. The list of errors you get will be the
error at each step of the fragment.

### Scoring Program Fragments Based On Error over Time

The last question is how to "score" each fragment based on the list of
errors we've found. Since we decided earlier that we're going to
assume that fragments produce a roughly constant amount of error each
iteration, like our sum fragment, fitting a linear line to the error
growth should do the trick. But when we do that, we'll find that the
fit is terrible, even on our sum fragment. So what happened?

It turns out, the error isn't actually always growing. In fact,
sometimes it's shrinking.  "That's weird, how could it be shrinking?"
you might think. Well, it turns out that whether the error of each
step is in the "positive" or "negative" direction depends entirely on
the current sum, and the item in the list we're adding.  It could be
that we add one item, which adds a bit of error to the answer, and
then we add another item, which subtracts a bit of error from the
answer, and the two cancel each other out.  Since we're looking at
randomly sampled lists as our inputs, the behavior we actually get is
a [random walk](https://en.wikipedia.org/wiki/Random_walk).  Luckily,
mathematicians have been studying random walks for a long time, so we
know that the random walk is bounded by a rough square root function,
instead of the linear function we expected.  By mapping this square
root space back on to a linear line by squaring all the points, we can
get our linear fit to work out properly. Now that we have a fit, we
can finally score our candidate fragments during search.

So there you have it. We have all the pieces to finally score program
fragments based on how fast their error grows as they loop. With this
scoring mechanism, we can finally work on searching through the space
of looping program fragments to find the ones with the best
accuracy. I hope after reading this, you have a sense of what it takes
to give a good measurement of how well behaved a program fragment with
loops is with respect to accuracy.

Edit 8/7/15: Fixed small errors and added clarifications
