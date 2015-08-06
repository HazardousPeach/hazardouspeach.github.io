---
title: Blog
layout: default
---

Blog
====

<table>
<tbody>
{% for post in site.posts %}
<tr><td>{{ post.date | date: "%-d %B %Y"}} -- </td><td><a href="{{ post.url }}">{{ post.title }}</a></td></tr>
{% endfor %}
</tbody>
</table>
