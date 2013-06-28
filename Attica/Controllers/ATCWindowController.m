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

static int SnippetKVOContext;
static NSString *const SEARCH_PREDICATE_FORMAT = @"(title contains[cd] %@ OR summary contains[cd] %@ OR shortcut contains[cd] %@)";

@interface ATCWindowController()
@property (nonatomic, strong) NSArray *snippetBindings;
@end

@implementation ATCWindowController

- (id)initWithBundle:(NSBundle *)bundle {
    self = [super init];
    if (self) {
        self.filterPredicate = [NSPredicate predicateWithValue:YES];
        self.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
        self.contentsFont = [NSFont fontWithName:@"Menlo" size:14];
        [self setWindow:[self mainWindowInBundle:bundle]];
        self.snippetManager = [[ATCSnippetManager alloc] init];
        self.snippetBindings = @[@"title",@"platform",@"language",@"summary",@"contents",@"shortcut"];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(snippetWillBeDeleted:) name:@"me.delisa.Attica.snippet-deletion" object:nil];
    }
    return self;
}

- (IBAction)addSnippet:(id)sender {
    self.selectedSnippet = [self.snippetManager createSnippet];
}

- (IBAction)deleteSelectedSnippet:(id)sender {
    [self.snippetManager deleteSnippet:self.selectedSnippet];
}

- (void)setSelectedSnippet:(ATCSnippet *)selectedSnippet {
    if (_selectedSnippet != selectedSnippet) {
        [self removeObserversOnSnippet:_selectedSnippet];

        _selectedSnippet = selectedSnippet;
        [self addObserversOnSnippet:_selectedSnippet];
    }
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    NSTableView *tableView = [notification object];
    self.selectedSnippet = [[self.snippetManager.snippets filteredArrayUsingPredicate:self.filterPredicate] sortedArrayUsingDescriptors:self.sortDescriptors][tableView.selectedRow];
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

#pragma mark - Private

- (void) snippetWillBeDeleted:(NSNotification *)notification {
    ATCSnippet *doomedSnippet = [notification object];
    if (doomedSnippet == self.selectedSnippet) {
        [self removeObserversOnSnippet:doomedSnippet];
    }
}

- (void) removeObserversOnSnippet:(ATCSnippet *)snippet {
    for (NSString *keyPath in self.snippetBindings) {
        [snippet removeObserver:self forKeyPath:keyPath context:&SnippetKVOContext];
    }
}

- (void)addObserversOnSnippet:(ATCSnippet *)snippet {
    for (NSString *keyPath in self.snippetBindings) {
        [snippet addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionNew context:&SnippetKVOContext];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    [(ATCSnippet *)object persistChanges];
}

- (NSWindow *)mainWindowInBundle:(NSBundle *)bundle {
    NSArray *nibElements;
    [bundle loadNibNamed:@"MainWindow" owner:self topLevelObjects:&nibElements];
    NSPredicate *windowPredicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return [evaluatedObject class] == [NSWindow class];
    }];

    return [nibElements filteredArrayUsingPredicate:windowPredicate][0];
}

@end
