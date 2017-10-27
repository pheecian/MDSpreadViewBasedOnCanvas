MDSpreadViewBasedOnCanvas
=================

![Screenshot](https://github.com/pheecian/MDSpreadViewBasedOnCanvas/raw/master/Artwork/IMG_0002.PNG)

Purpose
-------

`MDSpreadViewBasedOnCanvas` is a rewrite of `MDSpreadView` that allows for the display
of columns and column headers as well as rows. Instead of layout a lot of subviews or sublayers  
in a UIScrollView representing each cell, this implementation uses a customized UIView to draw  
every single pixel of a spreadsheet view. Test shows that in the case when there exist more than  
500 cells(with rich style) in one screen, MDSpreadView scrolls not smoothly. It is because   
too much time is consumed to handle a large scale viewGroup system with a large amout of subviews. 
But if only one customized UIView is handled by iOS Rendering System, life will be much better.


Notes
-----

 - An `MDSpreadViewCell` is created just like a `UITableViewCell` is -- try to 
 dequeue it from the spread view, otherwise create a new one, then 
 configure and return. But it is just a placeholder, instead of actual UIView.
 - The table headers are also made of cells, and are loaded just like 
 MDSpreadViewCells are.
 - Most part of rendered View Data will be reused with the assistance of CGLayer,
only delta part due to scroll need be re-rendered.

License
-------

Copyright (c) 2014 Dimitri Bouniol, Mochi Development, Inc.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software, associated artwork, and documentation files (the "Software"),
to deal in the Software without restriction, including without limitation the
rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
sell copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

1. The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
2. Neither the name of Mochi Development, Inc. nor the names of its
 contributors or products may be used to endorse or promote products
 derived from this software without specific prior written permission.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

Mochi Dev, and the Mochi Development logo are copyright Mochi Development, Inc.

Also, it'd be super awesome if you credited this page in your about screen :)

(We do this for you in [MDAboutController](https://github.com/mochidev/MDAboutControllerDemo)!)

Credits
-------

- Created by [Dimitri Bouniol](http://twitter.com/dimitribouniol) for [Mochi Development, Inc.](http://mochidev.com/)
- Contributed to by [Sonny Fazio](https://github.com/sonnyfazio) of [SonsterMedia](https://sonstermedia.com)
