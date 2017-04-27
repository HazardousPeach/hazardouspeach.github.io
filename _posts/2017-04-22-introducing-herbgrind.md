---
layout: post
title: "Introducing Herbgrind"
author: Alex Sanchez-Stern
---

Wow, it's been a long time since I posted anything here. If you've
read
the
[last post]({{ site.baseurl }}/2015/10/16/improving-accuracy-summation.html) on
this blog, you'll know that I was working on Herbie-like improvement
of looping programs. Well, it's been a long journey since then, and
the unexpected result is a new
tool, [Herbgrind](uwplse.github.io/herbgrind/), to help programmers
weed out dubious floating point code in large numerical programs.

![Herbgrind logo]({{ site.baseurl }}/images/full-logo.png){:style="width:50%" class="centered"}

So how did I get there from my Herbie-loops work? Let me tell you a
story.

Herbie has always been a very benchmark driven project. From day one
we had 28 main benchmarks that followed us throughout the project,
taken from Richard
Hamming's
[Numerical Methods for Scientists and Engineers](https://www.amazon.com/Numerical-Methods-Scientists-Engineers-Mathematics/dp/0486652416). Early
on we built a website to report Herbie's results on these benchmarks,
and we started running on them regularly even earlier.  This
benchmark-based approach served us well; it kept us from spending time
on features that weren't helpful, and kept us honest about Herbie's
abilities.

Because of our benchmarks, we never lacked for new ideas to add to
Herbie's search. All we ever had to do was pick a benchmark that
Herbie wasn't succeeding at, and ask ourselves how we would solve the
problem by hand. If we could encode that intuition into a search
process, we had ourselves a new search component. All of Herbie's
systems came about through this process, from simplification, to local
error, to recursive rewriting: we saw a concrete problem in one of our
benchmarks, and we tried to solve it in general.

So when it came time to work on loops, the first thing to do was
gather the benchmarks. Unfortunately, we couldn't find many looping
examples in books like Numerical Methods for Scientists and
Engineers. In fact, we couldn't really find them anywhere. Now, this
probably speaks as much to our unfamiliarity with the numerical
methods literature as anything, but the problem remained. We had no
benchmarks, and without benchmarks, we couldn't develop Herbie-loops
the way we'd developed Herbie.

The first thing I did was to try to write my own benchmarks. Sure,
they wouldn't be as authentic as ones in the wild, but it's a start. I
wrote some loops that calculate the mean of a list, and its variance
using two different formulas. I wrote a simple partial differential
equation solver, and gave it some differential equations to
solve. Then I implemented a hacky version
a
[Kahan Summation]({{ site.baseurl }}/2015/10/16/improving-accuracy-summation.html)
to improve them, and let it run.

It worked well. Too well. Pretty much every benchmark had its error
completely improved using this simple trick. It turns out, all the
benchmarks I came up with had at their heart, a sum of a bunch of
similar elements. I racked my brain for more complicated examples, but
I couldn't find any. I knew that big numerical programs had
challenging loops at their core, that needed more than my one simple
trick to improve them. But I needed to find them.

And so I set out to investigate the inaccurate floating point code in
large numerical programs, like [Gromacs](http://www.gromacs.org/),
and [CalculiX](http://www.calculix.de/).

I immediately hit a problem. I didn't understand the source code of
this software, even on a surface level. If I was going to find the
numerical issues in it, I would need
tools. [FpDebug](https://github.com/fbenz/FpDebug) was a step in the
right direction, but it wasn't quite what I needed. While it tells you
when floating point error occurs, it doesn't let you know where the
problematic values came from.

Luckily, building tools to help people with floating point is exactly
my area of expertise. And so, work on Herbgrind began.

![Herbgrind logo]({{ site.baseurl }}/images/full-logo.png){:style="width:50%" class="centered"}

Herbgrind is a dynamic analysis to help people track down dubious
floating point code in their programs. Because it works with Valgrind
at the binary level, it works on a variety of architectures and source
languages. All you need to do is run it on your binary with debug
information, on some input data that you think is representative. When
it finds floating point error that hurts your program, it'll let you
know, and try to tell you what computation caused it. The output looks
like this:

~~~
Result in main at diff-roots.c:21 (address 1)
47.252184 bits average error
64.000000 bits max error
Aggregated over 1000 instances
Influenced by erroneous expression:

    (FPCore (x)
      (- (sqrt (+ 1.000000 x)) (sqrt x)))
   in main at diff-roots.c:20 (address 400A08)
   47.252184 bits average error
   64.000000 bits max error
   47.250599 bits average local error
   64.000000 bits max local error
   Aggregated over 1000 instances
~~~

So that's Herbgrind, in a nutshell. In the next few weeks, I'm going
to try to explain how Herbgrind does what it does, and what the
process of developing it was like.
