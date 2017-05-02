---
title: Blog
layout: default
---

Blog
====

<table class="wide">
<tbody>
{% for post in site.posts %}
<tr><td class="datecell">{{ post.date | date: "%-d/%m/%Y"}}</td><td id="dashcell"></td><td id="postcell"><a href="{{ site.baseurl }}{{ post.url }}">{{ post.title }}</a></td></tr>
{% endfor %}
</tbody>
</table>
