---
layout: post
title: "Curious format character %r"
date: 2012-03-16 13:20
comments: true
categories:
- 规
tags: 
- python
- string
---

I am doing [Exercise 6](http://learnpythonthehardway.org/book/ex6.html) of *Learn Python the Hard Way* today, and a part of the code is like this:

``` py Exercise 6 http://learnpythonthehardway.org/book/ex6.html
x = "There are %d types of people." % 10
binary = "binary"
do_not = "don't"
y = "Those who know %s and those who %s." % (binary, do_not)

print x
print y

print "I said: %r." % x
print "I also said: '%s'." % y
```

And the result is like this:

``` console
$ python ex6.py
There are 10 types of people.
Those who know binary and those who don't.
I said: 'There are 10 types of people.'.
I also said: 'Those who know binary and those who don't.'.
```

Notice that there is a pair of quote around `%s` on line 10, but this is not the case for `%r` above.  Yet in the result both have quote around the content of string `x` and `y`.

Some searching leads me to a StackOverflow [question](http://stackoverflow.com/questions/4480278/list-of-python-format-characters) then the documentation of Python.  Turns out that while `%s` passes the value (string) to `str()`, `%r` passes the value to `retr()`.  The Python Tutorial put it like this:

{% blockquote Python Software Foundation http://docs.python.org/tutorial/inputoutput.html#fancier-output-formatting The Python Tutorial %}
The str() function is meant to return representations of values which are fairly human-readable, while repr() is meant to generate representations which can be read by the interpreter (or will force a SyntaxError if there is not equivalent syntax).
{% endblockquote %}

Naturally, to an interpreter, a string is not a string unless it is quoted.  Probably to ensure that strings are handled properly by interpreters, `retr()` is quite proactive at adding quotes to both ends of its argument:

``` pycon 
>>> a = 'hello world'
>>> repr(a)
"'hello world'"
>>> str(a)
'hello world'
>>> repr(repr(a))
'"\'hello world\'"'
```

The last input is especially interesting.  The outer `repr()` knows the difference between the string delimiter ``"`` and the single quotes as part of the string.  So why does it add another pair nevertheless?  Why the interpreter cannot just deal with a string and its quotes?
