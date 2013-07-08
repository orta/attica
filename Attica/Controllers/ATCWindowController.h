//
//  ATCWindowController.h
//
//  Copyright (c) 2013 Delisa Mason. http://delisa.me
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to
//  deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
//  IN THE SOFTWARE.

#import "ATCSnippetManager.h"
#import "ATCSnippet.h"

@interface ATCWindowController : NSWindowController<NSTableViewDelegate, NSControlTextEditingDelegate>

@property (nonatomic, strong) ATCSnippetManager *snippetManager;
@property (nonatomic, strong) ATCSnippet *selectedSnippet;
@property (nonatomic, strong) NSFont *contentsFont;
@property (nonatomic, retain) NSPredicate *filterPredicate;
@property (nonatomic, retain) NSArray *sortDescriptors;
@property (strong) IBOutlet NSArrayController *arrayController;
@property (strong) IBOutlet NSWindow *importWindow;
@property (weak) IBOutlet NSTextField *importURLField;

- (id)initWithBundle:(NSBundle *)bundle;
- (IBAction)addSnippet:(id)sender;
- (IBAction)deleteSelectedSnippet:(id)sender;
- (IBAction)showActionMenu:(NSButton *)sender;
- (IBAction)showImportDialog:(id)sender;
- (IBAction)exportSnippets:(id)sender;
- (IBAction)importSnippets:(NSButton *)sender;
- (IBAction)closeImportDialog:(NSButton *)sender;

@end
