# [[file:~/GitHub/J4Org.jl/docs/main.org::*A%20documented%20Julia%20=Foo=%20module][A documented Julia =Foo= module:1]]
module Foo

export Point, norm, foo
    
import Base: norm

#+Point L:Point_struct
# This is my Point structure
#
# *Example:*
#
# Creates a point $p$ of coordinates $(x=1,y=2)$.
#
# #+BEGIN_SRC julia :eval never :exports code
# p=Point(1,2)
# #+END_SRC
#
# You can add any valid Org mode directive. If you want to use
# in-documentation link, use [[norm_link_example][]]
#
struct Point
    x::Float64
    y::Float64
end

#+Point
# Creates Point at origin $(0,0)$ 
Point() = Point(0,0)

#+Enum
# An enum
@enum Alpha A=1 B C # just for example

#+Point,Method L:norm_link_example
# A simple function that computes $\sqrt{x^2+y^2}$
#
# *Example:*
#!p=Point(1.0,2.0);
#!norm(p) 
#
# See: [[Point_struct][]]
#
norm(p::Point)::Float64 = sqrt(p.x*p.x+p.y*p.y)

# +Method,Internal
# An internal function
#
# For symbol that are not exported, do not forget the "Foo." prefix:
# !p=Point(1.0,2.0)
# !Foo.foo(2.0,p)
foo(r::Float64,p::Point) = Point(r*p.x,r*p.y)

end
# A documented Julia =Foo= module:1 ends here
