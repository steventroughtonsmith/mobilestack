/*
 *     Generated by class-dump 3.1.2.
 *
 *     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2007 by Steve Nygard.
 */

#import <Foundation/Foundation.h>
#import "PSViewController.h"

@class NSArray, NSMutableArray, NSMutableDictionary, NSString, PSSpecifier, UIModalView, UIPreferencesTable, UITransitionView;

@interface PSListController : PSViewController
{
    NSMutableDictionary *_cells;
    BOOL _cachesCells;
    NSString *_title;
    UITransitionView *_view;
    UIPreferencesTable *_table;
    NSArray *_specifiers;
    id <PSBaseView> _detailController;
    id <PSBaseView> _previousController;
    NSMutableArray *_controllers;
    NSMutableDictionary *_specifiersByID;
    BOOL _keyboardWasVisible;
    BOOL _showingSetupController;
    BOOL _selectingRow;
    NSString *_specifierID;
    PSSpecifier *_specifier;
    NSMutableArray *_groups;
    NSMutableArray *_bundleControllers;
    BOOL _bundlesLoaded;
    struct CGRect _cellRect;
    UIModalView *_alertSheet;
}

+ (BOOL)displaysButtonBar;
- (void)setCachesCells:(BOOL)fp8;
- (id)description;
- (id)table;
- (id)bundle;
- (id)specifier;
- (id)loadSpecifiersFromPlistName:(id)fp8 target:(id)fp12;
- (id)specifiers;
- (void)_addIdentifierForSpecifier:(id)fp8;
- (void)_removeIdentifierForSpecifier:(id)fp8;
- (void)_setSpecifiers:(id)fp8;
- (void)setSpecifiers:(id)fp8;
- (void)reloadSpecifierAtIndex:(int)fp8 animated:(BOOL)fp12;
- (void)reloadSpecifierAtIndex:(int)fp8;
- (void)reloadSpecifier:(id)fp8 animated:(BOOL)fp12;
- (void)reloadSpecifier:(id)fp8;
- (void)reloadSpecifierID:(id)fp8 animated:(BOOL)fp12;
- (void)reloadSpecifierID:(id)fp8;
- (int)indexOfSpecifierID:(id)fp8;
- (int)indexOfSpecifier:(id)fp8;
- (BOOL)containsSpecifier:(id)fp8;
- (int)indexOfGroup:(int)fp8;
- (int)numberOfGroups;
- (id)specifierAtIndex:(int)fp8;
- (BOOL)getGroup:(int *)fp8 row:(int *)fp12 ofSpecifierID:(id)fp16;
- (BOOL)getGroup:(int *)fp8 row:(int *)fp12 ofSpecifier:(id)fp16;
- (BOOL)_getGroup:(int *)fp8 row:(int *)fp12 ofSpecifierAtIndex:(int)fp16 groups:(id)fp20;
- (BOOL)getGroup:(int *)fp8 row:(int *)fp12 ofSpecifierAtIndex:(int)fp16;
- (int)rowsForGroup:(int)fp8;
- (id)specifiersInGroup:(int)fp8;
- (void)insertSpecifier:(id)fp8 atIndex:(int)fp12 animated:(BOOL)fp16;
- (void)insertSpecifier:(id)fp8 afterSpecifier:(id)fp12 animated:(BOOL)fp16;
- (void)insertSpecifier:(id)fp8 afterSpecifierID:(id)fp12 animated:(BOOL)fp16;
- (void)insertSpecifier:(id)fp8 atEndOfGroup:(int)fp12 animated:(BOOL)fp16;
- (void)insertSpecifier:(id)fp8 atIndex:(int)fp12;
- (void)insertSpecifier:(id)fp8 afterSpecifier:(id)fp12;
- (void)insertSpecifier:(id)fp8 afterSpecifierID:(id)fp12;
- (void)insertSpecifier:(id)fp8 atEndOfGroup:(int)fp12;
- (void)insertContiguousSpecifiers:(id)fp8 atIndex:(int)fp12 animated:(BOOL)fp16;
- (void)insertContiguousSpecifiers:(id)fp8 afterSpecifier:(id)fp12 animated:(BOOL)fp16;
- (void)insertContiguousSpecifiers:(id)fp8 afterSpecifierID:(id)fp12 animated:(BOOL)fp16;
- (void)insertContiguousSpecifiers:(id)fp8 atEndOfGroup:(int)fp12 animated:(BOOL)fp16;
- (void)insertContiguousSpecifiers:(id)fp8 atIndex:(int)fp12;
- (void)insertContiguousSpecifiers:(id)fp8 afterSpecifier:(id)fp12;
- (void)insertContiguousSpecifiers:(id)fp8 afterSpecifierID:(id)fp12;
- (void)insertContiguousSpecifiers:(id)fp8 atEndOfGroup:(int)fp12;
- (void)addSpecifier:(id)fp8;
- (void)addSpecifier:(id)fp8 animated:(BOOL)fp12;
- (void)addSpecifiersFromArray:(id)fp8;
- (void)addSpecifiersFromArray:(id)fp8 animated:(BOOL)fp12;
- (void)removeSpecifier:(id)fp8 animated:(BOOL)fp12;
- (void)removeSpecifierID:(id)fp8 animated:(BOOL)fp12;
- (void)removeSpecifierAtIndex:(int)fp8 animated:(BOOL)fp12;
- (void)removeSpecifier:(id)fp8;
- (void)removeSpecifierID:(id)fp8;
- (void)removeSpecifierAtIndex:(int)fp8;
- (void)removeLastSpecifier;
- (void)removeLastSpecifierAnimated:(BOOL)fp8;
- (BOOL)_canRemoveSpecifiers:(id)fp8;
- (void)removeContiguousSpecifiers:(id)fp8 animated:(BOOL)fp12;
- (void)removeContiguousSpecifiers:(id)fp8;
- (void)replaceContiguousSpecifiers:(id)fp8 withSpecifiers:(id)fp12;
- (void)replaceContiguousSpecifiers:(id)fp8 withSpecifiers:(id)fp12 animated:(BOOL)fp16;
- (void)_loadBundleControllers;
- (void)_unloadBundleControllers;
- (void)suspend;
- (void)dealloc;
- (id)initForContentSize:(struct CGSize)fp8;
- (id)navigationTitle;
- (id)_createGroupIndices:(id)fp8;
- (void)createGroupIndices;
- (void)loseFocus;
- (void)reload;
- (void)reloadSpecifiers;
- (void)setSpecifierID:(id)fp8;
- (id)specifierID;
- (void)setTitle:(id)fp8;
- (id)title;
- (void)viewDidBecomeVisible;
- (void)viewWillRedisplay;
- (int)numberOfGroupsInPreferencesTable:(id)fp8;
- (BOOL)preferencesTable:(id)fp8 isLabelGroup:(int)fp12;
- (int)preferencesTable:(id)fp8 numberOfRowsInGroup:(int)fp12;
- (id)lastController;
- (id)cachedCellForSpecifier:(id)fp8;
- (id)cachedCellForSpecifierID:(id)fp8;
- (id)table:(id)fp8 cellForRow:(int)fp12 column:(id)fp16;
- (float)preferencesTable:(id)fp8 heightForRow:(int)fp12 inGroup:(int)fp16 withProposedHeight:(float)fp20;
- (id)preferencesTable:(id)fp8 titleForGroup:(int)fp12;
- (id)preferencesTable:(id)fp8 cellForGroup:(int)fp12;
- (id)preferencesTable:(id)fp8 cellForRow:(int)fp12 inGroup:(int)fp16;
- (void)viewWillBecomeVisible:(void *)fp8;
- (void)_unselectTable;
- (void)selectRowWithoutNotification:(int)fp8;
- (void)showConfirmationSheetForSpecifier:(id)fp8;
- (BOOL)performActionForSpecifier:(id)fp8;
- (void)tableSelectionDidChange:(id)fp8;
- (void)alertSheet:(id)fp8 buttonClicked:(int)fp12;
- (void)_insertControllerUnderSetupController:(id)fp8;
- (id)specifierForID:(id)fp8;
- (void)pushController:(id)fp8 animate:(BOOL)fp12;
- (void)pushController:(id)fp8;
- (void)handleURL:(id)fp8;
- (void)_showKeyboard;
- (void)transitionViewDidComplete:(id)fp8;
- (id)view;
- (BOOL)popController;
- (void)_clearParentControllerFromChildren;
- (void)_removeController;
- (BOOL)popControllerWithAnimation:(BOOL)fp8;
- (void)navigationBarButtonClicked:(int)fp8;
- (void)reloadIconForSpecifierForBundle:(id)fp8;
- (void)showKeyboardWithKeyboardType:(int)fp8;

@end

