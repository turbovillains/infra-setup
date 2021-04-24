sed.md
===

From ctdb callout scripts
```
/^\[gluster-docs\]/ {:a' -e 'n;
	/available = no/H;
	/^$/! { $!ba; };
	x;
	/./!{
	  s/^/available = no/;
	  $! {G; x };
	  $H;
	 };
	s/.*//;
	x; 
};
```

By using N and D commands, sed can apply regular expressions on multiple lines (that is, multiple lines are stored in the pattern space, and the regular expression works on it):

:a create the label a 

x swap hold and pattern space 

h Replace the contents of the hold space with the contents of the pattern space.

H function appends the contents of the pattern space to the contents of the holding area. The former and new contents are separated by a newline.

G function appends the contents of the holding area to the contents of the pattern space. The former and new contents are separated by a newline