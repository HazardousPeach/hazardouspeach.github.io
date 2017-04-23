---
title: Blog
layout: default
---

Blog
====

<table>
<tbody>
{% for post in site.posts %}
<tr><td id="datecell">{{ post.date | date: "%-d %B %Y"}}</td><td id="dashcell"> -- </td><td id="postcell"><a href="{{ site.baseurl }}{{ post.url }}">{{ post.title }}</a></td></tr>
{% endfor %}
</tbody>
</table>
