---
author: Alex Sanchez-Stern
layout: default
---
![Alex Sanchez-Stern]({{ site.url }}{{ site.baseurl }}/images/me4.png){: .authorpicture }

Alex Sanchez-Stern
==================

Hey I'm Alex Sanchez-Stern, I'm a Postdoctoral researcher at UMass
Amherst. I graduated from the University of Washington with a Masters
degree in the Spring of 2016, and finished my PhD at UC San Diego in
the Spring of 2021. I'm also part of the team at the UW that built
[Herbie](https://herbie.uwplse.org). I'm generally interested in using
programming language techniques to bring hard-fought domain expertise
to more everyday programmers. My PhD thesis was on
[Proverbot9001](https://proverbot9001.ucsd.edu), a neural-guided proof
search tool described on the [projects]({{ site.url }}{{ site.baseurl
}}/projects.html) page, and in the MAPL paper below.

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

You can reach me at [alex.sanchezstern@gmail.com](alex.sanchezstern@gmail.com). I'm
also [on GitHub](https://github.com/HazardousPeach).
