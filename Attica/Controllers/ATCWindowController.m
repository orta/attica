//
//  ATCWindowController.m
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

#import "ATCWindowController.h"

static NSString *const SEARCH_PREDICATE_FORMAT = @"(title contains[cd] %@ OR summary contains[cd] %@ OR shortcut contains[cd] %@)";

@interface ATCWindowController()
@property (nonatomic, strong) NSArray *snippetBindings;
@end

@implementation ATCWindowController

- (id)initWithBundle:(NSBundle *)bundle {
    self = [super init];
    if (self) {
        self.filterPredicate = [NSPredicate predicateWithValue:YES];
        self.contentsFont = [NSFont fontWithName:@"Menlo" size:14];
        [self setWindow:[self mainWindowInBundle:bundle]];
        self.snippetManager = [[ATCSnippetManager alloc] init];
        self.snippetBindings = @[@"title",@"platform",@"language",@"summary",@"contents",@"shortcut"];
    }
    return self;
}

- (void)setSelectedSnippet:(ATCSnippet *)selectedSnippet {
    if (_selectedSnippet != selectedSnippet) {
        for (NSString *keyPath in self.snippetBindings) {
            [_selectedSnippet removeObserver:self forKeyPath:keyPath];
        }
        _selectedSnippet = selectedSnippet;
        for (NSString *keyPath in self.snippetBindings) {
            [_selectedSnippet addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionNew context:NULL];
        }
    }
}

- (NSWindow *)mainWindowInBundle:(NSBundle *)bundle {
    NSArray *nibElements;
    [bundle loadNibNamed:@"MainWindow" owner:self topLevelObjects:&nibElements];
    NSPredicate *windowPredicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return [evaluatedObject class] == [NSWindow class];
    }];

    NSWindow *window = [nibElements filteredArrayUsingPredicate:windowPredicate][0];

    return window;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    NSTableView *tableView = [notification object];
    self.selectedSnippet = [self.snippetManager.snippets filteredArrayUsingPredicate:self.filterPredicate][tableView.selectedRow];
}

- (void)controlTextDidChange:(NSNotification *)notification {
    NSSearchField *searchField = [notification object];
    NSString *searchText = searchField.stringValue;
    if (searchText.length > 0) {
        self.filterPredicate = [NSPredicate predicateWithFormat:SEARCH_PREDICATE_FORMAT, searchText, searchText, searchText];
    } else {
        self.filterPredicate = [NSPredicate predicateWithValue:YES];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    [self.selectedSnippet persistChanges];
}

@end
