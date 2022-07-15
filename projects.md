---
title: Projects
author: Alex Sanchez-Stern
layout: default
---

Projects
========

<div markdown="1" class="project">
<img src="{{ site.url }}{{ site.baseurl }}/images/passport.png" class="projectlogo"/>

<div markdown="1" class="projectdesc">

[Passport](https://github.com/LASER-UMASS/Passport/) is a project
studying new ways of encoding identifiers for neural models of code in
the context of learning-guided foundational verification. It proposes
three novel encoding mechanisms for identifiers: a method of indexing
common identifiers while storing the category of every identifier
(local variable, definition, or constructor), an encoding of the
subwords which make up the identifier name, and an encoding of the
file and module locations where the identifiers are defined. Passport
is [free and open source
software](https://github.com/LASER-UMASS/Passport/), and you can find
the pre-print paper draft on
[arXiv](https://arxiv.org/abs/2204.10370).
</div>
</div>

<div markdown="1" class="project">

<img src="https://proverbot9001.ucsd.edu/images/proverbot9001-logo-with-text.png" class="projectlogo"/>

<div markdown="1" class="projectdesc">

[Proverbot9001](https://proverbot9001.ucsd.edu) is a ongoing initiative
which uses neural network guided proof search to solve proof
obligations in the Coq proof assistant. It has been shown to
outperform enumerative and solver-based proof search tools, as well as
other state-of-the-art machine-learning based proof search
tools. Proverbot9001 is [free and open source
software](https://github.com/UCSD-PL/proverbot9001), published at MAPL
2020 in June 2020. You can find an extended version of the paper here
[on my site](papers/proverbot9001.pdf).

</div>
</div>

### REPLica

REPLica is a tool that instruments Coq's interaction model in order to
collect fine-grained data on proof developments, as well as a
user-study initiative which used the REPLica tool to collect data over
the span of a month from a group of intermediate through expert proof
engineers. REPLica is [free and open source (as well as
data)](https://github.com/uwplse/coq-change-analytics), published at
CPP 2020 as [REPLica: REPL Instrumentation for Coq
Analysis](papers/replica.pdf).

<div markdown="1" class="project">
<img src="{{ site.url }}{{ site.baseurl }}/images/caravan-placeholder-logo.png" class="projectlogo"/>

<div markdown="1" class="projectdesc">

Scooter & Sidecar is a new tool for secure database migrations that
respect data access policies. The project consists of several
languages, for specifying data access policies, specifying migration
actions, and maniuplating database values. It also includes tooling
for interacting with those languages, automatically enforcing the
policies at runtime, running the migrations over existing database,
and statically checking that the migrations do not leak data
unintentionally. Caravan is an ongoing work in collaboration with John
Renner (UCSD), Fraser Brown (Stanford), and Deian Stefan (UCSD).

</div>
</div>


<div markdown="1" class="project">
<img src="{{ site.url }}{{ site.baseurl }}/images/herbgrind_logo.png" class="projectlogo"/>

<div markdown="1" class="projectdesc">

[Herbgrind](http://herbgrind.ucsd.edu) is a debugging tool to help
developers find the *root cause* of floating-point inaccuracy in large
numerical software. It runs directly on program binaries, and produces
reports about inaccuracies found that affect program
outputs. Herbgrind is [free and open source
software](https://github.com/uwplse/herbgrind), published at PLDI 2018
as [Finding Root Causes of Floating Point
Error](http://herbgrind.ucsd.edu/herbgrind-pldi18.pdf).

</div>
</div>

<div markdown="1" class="project">
<img src="https://fpbench.org/img/logo.png" class="projectlogo"/>

<div markdown="1" class="projectdesc">

[fpbench](https://fpbench.org) is a benchmark format and suite for the
development of floating point tooling. I co-authored the original
FPBench paper, published at NSV 2016 as [Toward a Standard Benchmark
Format and Suite for Floating-Point
Analysis](https://fpbench.org/nsv16-paper.pdf). Since then, the project
has grown to include instutitions and teams across the world.

</div>
</div>

<div markdown="1" class="project">
<img src="https://herbie.uwplse.org/logo.png" class="projectlogo"/>

<div markdown="1" class="projectdesc">
[Herbie](https://herbie.uwplse.org) is a tool to help scientists and
programmers write accurate floating point code more easily. You give
it a floating point expression, and it tests it against hundreds of
points to find a version that's more accurate. Herbie is [open source
software](https://github.com/uwplse/herbie), published at PLDI 2015 as
[Automatically Improving Accuracy for Floating Point
Expressions](https://herbie.uwplse.org/pldi15-paper.pdf).

</div>
</div>
