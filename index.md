---
author: Alex Sanchez-Stern
layout: default
---
![Alex Sanchez-Stern]({{ site.url }}{{ site.baseurl }}/images/me3.png){: .authorpicture }

Alex Sanchez-Stern
==================

Hey I'm Alex Sanchez-Stern, I'm a PhD student at the University of
California San Diego. I'm also part of the team at the UW that built
[Herbie](https://herbie.uwplse.org). I graduated from the UW with a
Masters degree in the Spring of 2016, and started my PhD at UCSD in
the Fall of 2016; I'm graduating in the Spring of 2021. I'm generally
interested in using programming language techniques to bring
hard-fought domain expertise to more everyday programmers. My thesis
is on Proverbot9001, a neural-guided proof search tool described on
the [projects]({{ site.url }}{{ site.baseurl }}/projects.html) page,
and in the MAPL paper below.

Publications
------------
{% for pub in site.data.publications %}
{% include publication.html
    paper=pub.paper
    website=pub.website
    github=pub.github
    title=pub.title
    conference=pub.conference
    authors=pub.authors
    id=forloop.index
    bibtex=pub.bibtex
%}
{% endfor %}

Contact
-------

You can reach me at [alexss@eng.ucsd.edu](mailto:alexss@eng.ucsd.edu)
my university email address. I'm
also [on GitHub](https://github.com/HazardousPeach).
