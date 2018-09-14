//
//  GPRNode+Graph.h
//  GPReact
//
//  Created by Liyanwei on 2018/9/14.
//  Copyright © 2018年 Liyanwei. All rights reserved.
//

#import "GPRNode.h"

NS_ASSUME_NONNULL_BEGIN

@interface GPRNode (Graph)
/**
 Returns a string to describe the topology associated with the receiver.
 The string is dot language code used for generating a static image
 via *graphiz* tool while debugging. See also
 [The dot language](https://www.graphviz.org/doc/info/lang.html) .
 
 Usage
 1. Install 'graphviz' command line tool in Mac OS system
 
 <pre>@textblock
 
 brew install graphviz
 
 @/textblock</pre>
 
 2. Put the string returned from this method into a text file, such as test.dot
 
 3. Generate image
 
 <pre>@textblock
 
 circo -Tpdf test.dot -o test.pdf && open test.pdf
 
 @/textblock</pre>
 
 @return    dot language string corresponding to GraphViz
 */
- (NSString *) graph;
@end

NS_ASSUME_NONNULL_END
