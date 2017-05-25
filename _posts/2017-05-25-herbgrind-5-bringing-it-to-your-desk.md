---
layout: post
title: "Herbgrind Part 5: Bringing it to Your Desk"
author: Alex Sanchez-Stern
---

Welcome back to my series of posts on Herbgrind, a dynamic analysis
tool that finds floating point issues in compiled programs. The
purpose of this series is to explain how Herbgrind works and the
principles behind its design. To do that, we started with a simple
hypothetical computer called the "Float Machine", which is just enough
to capture the interesting floating point behavior of a real computer,
like the one that's probably sitting on your desk. Now, we're bringing
Herbgrind's analysis to the real world, making it computable and fast.

![Herbgrind logo]({{ site.baseurl }}/images/full-logo.png){:style="width:30%" class="centered"}

In the last four posts in the series, we built up Herbgrind for
the
[Float Machine]({{ site.baseurl }}/2017/04/27/herbgrind-1-the-float-machine.html),
a hypothetical machine which executes floating point programs. We
showed that Herbgrind is actually composed of three machines run on
top of the float machine, sharing the program.

The first,
the
[Real Machine]({{ site.baseurl }}/2017/05/07/herbgrind-2-the-real-machine.html),
computes the program with perfect accuracy, exactly as we would in the
pure mathematical real numbers. Then, it compares the final result
computed this way to the final result computed by the float machine,
using floating point numbers. By measuring the difference between the
two outputs, the Real Machine can compute the "floating point error"
of the program.

The second machine,
the
[Local Machine]({{ site.baseurl }}/2017/05/10/herbgrind-3-the-local-machine.html),
computes each operation in a "locally approximate" way. This means
taking exact inputs, and rounding them to floats, and then executing
the float operation using them. With this method, the Local Machine
can detect at which operations error first appears, so it can start to
zero in on the cause of the error. The Local Machine also tracks what
outputs these sources of error influence, so that the user doesn't
have to worry about error that doesn't affect the results they care
about.

Finally,
the
[Symbolic Machine]({{ site.baseurl }}/2017/05/20/herbgrind-4-the-symbolic-machien.html) tracks
how each value in the program was built. This way, when the Local
Machine detects error in an operation, they Symbolic Machine can tell
the user what operations preceded the error, and thus help the user
diagnose and fix the error.

Now that we've defined what Herbgrind does in the abstract, it's time
to bring the power of Herbgrind to your desk. Computers in the real
world have new challenges that we didn't have to deal with in the
Float Machine, and Herbgrind has a solution to each one.

Herbgrind and Valgrind: Implementing Dynamic Analysis
-----------------------------------------------------

Floating Point Values: Dealing with SIMD on x86 (and Friends)
-------------------------------------------------------------

Types, Types, and Types: Minimizing the Cost of Tracking Values
---------------------------------------------------------------

The Real Machine: Computing with Real Numbers?
----------------------------------------------

Going to the Library: Intercepting Math Library Calls
-----------------------------------------------------

Dealing with Expert Code: Compensation Detection
------------------------------------------------

Bits and Bytes: Detecting Disguised Float Operations
----------------------------------------------------

Lazyboy: Last Minute Shadowing
------------------------------

Working Together: Sharing Shadows
---------------------------------

Slow and Steady: Generalizing Symbolic Expressions Incrementally
----------------------------------------------------------------

A Little Bit Wrong: Approximate Expressions
-------------------------------------------
