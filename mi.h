/*
 * mi.h
 */

#import <AppKit/AppKit.h>
#import <ScriptingBridge/ScriptingBridge.h>


@class miApplication, miWindow, miDocument, miParagraph, miWord, miCharacter, miInsertionPoint, miSelectionObject, miIndexwindow, miIndexrecord, miIndexgroup;

enum miSavo {
	miSavoYes = 'yes ' /* Save objects now */,
	miSavoNo = 'no  ' /* Do not save objects */,
	miSavoAsk = 'ask ' /* Ask the user whether to save */
};
typedef enum miSavo miSavo;

enum miRetc {
	miRetcCR = 'CR  ' /* CR (Mac) */,
	miRetcCRLF = 'CRLF' /* CR+LF (Windows) */,
	miRetcLF = 'LF\000\000' /* LF (UNIX) */
};
typedef enum miRetc miRetc;

enum miEpth {
	miEpthPartial = 'part' /* partial path */,
	miEpthFull = 'full' /* full path */
};
typedef enum miEpth miEpth;



/*
 * Standard suite
 */

// An application program
@interface miApplication : SBApplication

- (SBElementArray *) windows;
- (SBElementArray *) documents;
- (SBElementArray *) indexwindows;

- (void) open:(NSArray *)x;  // Open the specified object(s)
- (void) print:(NSArray *)x;  // Print the specified object(s)
- (void) quit;  // Quit Navigator
- (void) run;  // Sent to an application when it is double-clicked
- (void) selectTo:(SBObject *)to;  // Select the specified object

@end

// A Window
@interface miWindow : SBObject

@property NSRect bounds;  // the boundary rectangle for the window
@property (readonly) BOOL closeable;  // Does the window have a close box?
@property (readonly) BOOL titled;  // Does the window have a title bar?
@property NSInteger index;  // the index of the window in the application
@property (readonly) BOOL floating;  // Does the window float?
@property (readonly) BOOL modal;  // Is the window modal?
@property (readonly) BOOL resizable;  // Is the window resizable?
@property (readonly) BOOL zoomable;  // Is the window zoomable?
@property BOOL zoomed;  // Is the window zoomed?
@property (copy) NSString *name;  // the title of the window
@property BOOL visible;  // Is the window visible?
@property (readonly) NSPoint position;  // upper left coordinates of window

- (void) closeSaving:(miSavo)saving in:(NSURL *)in_;  // Close an object
- (NSInteger) dataSize;  // Return the size in bytes of an object
- (void) delete;  // Delete an element from an object
- (void) print;  // Print the specified object(s)
- (void) openAs:(NSString *)as;  // Open the specified object(s)
- (void) saveIn:(NSURL *)in_ as:(NSNumber *)as;  // save a set of objects
- (void) selectTo:(SBObject *)to;  // Select the specified object
- (BOOL) exists;  // Verify if an object exists
- (void) collapse;  // collapse indexgroup
- (void) expand;  // expand indexgroup

@end

// A Document
@interface miDocument : SBObject

- (SBElementArray *) paragraphs;
- (SBElementArray *) words;
- (SBElementArray *) characters;
- (SBElementArray *) insertionPoints;
- (SBElementArray *) selectionObjects;

@property (copy, readonly) NSURL *file;  // the file specification of the document
@property (copy) NSString *name;  // the file name of the document
@property (readonly) BOOL modified;  // Has the document been modified since the last save?
@property (copy) NSString *mode;  // mode name, for example "HTML" or "TeX" or "C",etc.
@property (copy) NSString *textEncoding;  // Text Encoding
@property (copy) NSString *characterCode;  // Text Encoding (old name)
@property miRetc returnCode;  // return code
@property (copy) NSString *type;  // file type
@property (copy) NSString *creator;  // file creator
@property NSInteger windowindex;  // the index of the window in the application
@property NSInteger index;  // the index of the document window
@property (copy) NSString *header;  // information header string
@property (copy) NSString *font;  // Font name
@property NSInteger size;  // Size of font

- (void) closeSaving:(miSavo)saving in:(NSURL *)in_;  // Close an object
- (NSInteger) dataSize;  // Return the size in bytes of an object
- (void) delete;  // Delete an element from an object
- (void) print;  // Print the specified object(s)
- (void) openAs:(NSString *)as;  // Open the specified object(s)
- (void) saveIn:(NSURL *)in_ as:(NSNumber *)as;  // save a set of objects
- (void) selectTo:(SBObject *)to;  // Select the specified object
- (BOOL) exists;  // Verify if an object exists
- (void) collapse;  // collapse indexgroup
- (void) expand;  // expand indexgroup

@end

// A paragraph until carige return code
@interface miParagraph : SBObject

- (SBElementArray *) words;
- (SBElementArray *) characters;
- (SBElementArray *) insertionPoints;

@property (readonly) NSInteger index;  // the paragraph number in the document
@property (copy) NSString *content;  // the content text of the paragraph

- (void) closeSaving:(miSavo)saving in:(NSURL *)in_;  // Close an object
- (NSInteger) dataSize;  // Return the size in bytes of an object
- (void) delete;  // Delete an element from an object
- (void) print;  // Print the specified object(s)
- (void) openAs:(NSString *)as;  // Open the specified object(s)
- (void) saveIn:(NSURL *)in_ as:(NSNumber *)as;  // save a set of objects
- (void) selectTo:(SBObject *)to;  // Select the specified object
- (BOOL) exists;  // Verify if an object exists
- (void) collapse;  // collapse indexgroup
- (void) expand;  // expand indexgroup

@end

// A word (an alphabet sequence) or a non-alphabet (but not space) letter
@interface miWord : SBObject

- (SBElementArray *) characters;
- (SBElementArray *) insertionPoints;

@property (readonly) NSInteger index;  // the word index in the document
@property (copy) NSString *content;  // the content of the word

- (void) closeSaving:(miSavo)saving in:(NSURL *)in_;  // Close an object
- (NSInteger) dataSize;  // Return the size in bytes of an object
- (void) delete;  // Delete an element from an object
- (void) print;  // Print the specified object(s)
- (void) openAs:(NSString *)as;  // Open the specified object(s)
- (void) saveIn:(NSURL *)in_ as:(NSNumber *)as;  // save a set of objects
- (void) selectTo:(SBObject *)to;  // Select the specified object
- (BOOL) exists;  // Verify if an object exists
- (void) collapse;  // collapse indexgroup
- (void) expand;  // expand indexgroup

@end

// An any kind of character ( 2-byte character is counted as one character )
@interface miCharacter : SBObject

- (SBElementArray *) insertionPoints;

@property (readonly) NSInteger index;  // the character index in the document
@property (copy) NSString *content;  // the content of the character

- (void) closeSaving:(miSavo)saving in:(NSURL *)in_;  // Close an object
- (NSInteger) dataSize;  // Return the size in bytes of an object
- (void) delete;  // Delete an element from an object
- (void) print;  // Print the specified object(s)
- (void) openAs:(NSString *)as;  // Open the specified object(s)
- (void) saveIn:(NSURL *)in_ as:(NSNumber *)as;  // save a set of objects
- (void) selectTo:(SBObject *)to;  // Select the specified object
- (BOOL) exists;  // Verify if an object exists
- (void) collapse;  // collapse indexgroup
- (void) expand;  // expand indexgroup

@end

// An insertion location between a character
@interface miInsertionPoint : SBObject

@property (readonly) NSInteger index;  // the insertion point index in the document

- (void) closeSaving:(miSavo)saving in:(NSURL *)in_;  // Close an object
- (NSInteger) dataSize;  // Return the size in bytes of an object
- (void) delete;  // Delete an element from an object
- (void) print;  // Print the specified object(s)
- (void) openAs:(NSString *)as;  // Open the specified object(s)
- (void) saveIn:(NSURL *)in_ as:(NSNumber *)as;  // save a set of objects
- (void) selectTo:(SBObject *)to;  // Select the specified object
- (BOOL) exists;  // Verify if an object exists
- (void) collapse;  // collapse indexgroup
- (void) expand;  // expand indexgroup

@end

// the selection or caret
@interface miSelectionObject : SBObject

- (SBElementArray *) words;
- (SBElementArray *) characters;
- (SBElementArray *) insertionPoints;

@property (copy) NSString *content;  // the content string of the selection object

- (void) closeSaving:(miSavo)saving in:(NSURL *)in_;  // Close an object
- (NSInteger) dataSize;  // Return the size in bytes of an object
- (void) delete;  // Delete an element from an object
- (void) print;  // Print the specified object(s)
- (void) openAs:(NSString *)as;  // Open the specified object(s)
- (void) saveIn:(NSURL *)in_ as:(NSNumber *)as;  // save a set of objects
- (void) selectTo:(SBObject *)to;  // Select the specified object
- (BOOL) exists;  // Verify if an object exists
- (void) collapse;  // collapse indexgroup
- (void) expand;  // expand indexgroup

@end

// An index window
@interface miIndexwindow : SBObject

- (SBElementArray *) indexrecords;
- (SBElementArray *) indexgroups;

@property (copy, readonly) NSURL *file;  // the file specification of the indexwindow
@property (copy) NSString *name;  // the title of the indexwindow
@property BOOL modified;  // Has the document been modified since the last save?
@property NSInteger filewidth;  // width of file tag
@property NSInteger infowidth;  // width of comment tag
@property NSInteger fileorder;  // order of file tag
@property NSInteger infoorder;  // order of comment tag
@property (readonly) miEpth path;  // saving type of path
@property (readonly) NSInteger windowindex;  // index of window
@property BOOL asksaving;  // whether ask saving or not when closing

- (void) closeSaving:(miSavo)saving in:(NSURL *)in_;  // Close an object
- (NSInteger) dataSize;  // Return the size in bytes of an object
- (void) delete;  // Delete an element from an object
- (void) print;  // Print the specified object(s)
- (void) openAs:(NSString *)as;  // Open the specified object(s)
- (void) saveIn:(NSURL *)in_ as:(NSNumber *)as;  // save a set of objects
- (void) selectTo:(SBObject *)to;  // Select the specified object
- (BOOL) exists;  // Verify if an object exists
- (void) collapse;  // collapse indexgroup
- (void) expand;  // expand indexgroup

@end

// index record of index window
@interface miIndexrecord : SBObject

@property (copy) NSURL *file;  // file information of index
@property NSInteger startposition;  // start position of index
@property NSInteger endposition;  // end position of index
@property NSInteger paragraph;  // paragraph number
@property (copy) NSString *comment;  // comment of index

- (void) closeSaving:(miSavo)saving in:(NSURL *)in_;  // Close an object
- (NSInteger) dataSize;  // Return the size in bytes of an object
- (void) delete;  // Delete an element from an object
- (void) print;  // Print the specified object(s)
- (void) openAs:(NSString *)as;  // Open the specified object(s)
- (void) saveIn:(NSURL *)in_ as:(NSNumber *)as;  // save a set of objects
- (void) selectTo:(SBObject *)to;  // Select the specified object
- (BOOL) exists;  // Verify if an object exists
- (void) collapse;  // collapse indexgroup
- (void) expand;  // expand indexgroup

@end

// group of index records
@interface miIndexgroup : SBObject

- (SBElementArray *) indexrecords;

@property (copy) NSString *comment;  // titile of group

- (void) closeSaving:(miSavo)saving in:(NSURL *)in_;  // Close an object
- (NSInteger) dataSize;  // Return the size in bytes of an object
- (void) delete;  // Delete an element from an object
- (void) print;  // Print the specified object(s)
- (void) openAs:(NSString *)as;  // Open the specified object(s)
- (void) saveIn:(NSURL *)in_ as:(NSNumber *)as;  // save a set of objects
- (void) selectTo:(SBObject *)to;  // Select the specified object
- (BOOL) exists;  // Verify if an object exists
- (void) collapse;  // collapse indexgroup
- (void) expand;  // expand indexgroup

@end

