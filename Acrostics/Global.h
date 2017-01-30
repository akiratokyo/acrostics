//  Copyright (c) 2012-2015 Egghead Games LLC. All rights reserved.

#ifndef Resume_Global_h
#define Resume_Global_h

//application's definitions
#define SOUND @"sound"
#define SOUND_ON @"on"
#define SOUND_OFF @"off"

#define QUIT_PUZZLE @"quit_puzzle"
#define FONT_INSTALLED @"font_installed"
#define GRID_SECTION_DECREASE @"grid_section_decrease"
#define CLUES_SECTION_COUNT @"clues_section_count"

#define VKSafeRelease(object) \
if (object != nil) { \
    [object release]; \
    object = nil; \
}

// selection colors
#define MAIN_SELECTION_COLOR        [UIColor colorWithRed:1.f green:184/255.0f blue:69/255.0f alpha:1.0f]
#define SECONDARY_SELECTION_COLOR   [UIColor colorWithRed:255/255.0f green:242/255.0f blue:221/255.0f alpha:1.0f]
#define BLUE_COLOR                  [UIColor colorWithRed:20/255.0f green:85/255.0f blue:137/255.0f alpha:1.0f]
#define GRID_BACKGROUND_COLOR        [UIColor colorWithRed:51/255.0f green:51/255.0f blue:51/255.0f alpha:1.0f]

//add -DDEBUG flag to c flags
#ifdef DEBUG 
# define DLog(...) NSLog(__VA_ARGS__) 
#else 
# define DLog(...) /* */
#endif 
#define ALog(...) NSLog(__VA_ARGS__)



//Set users Default values in system
#define getVal(key) [[NSUserDefaults standardUserDefaults] objectForKey:key]
#define getValDef(key,defaultVal) [[NSUserDefaults standardUserDefaults] objectForKey:key] == nil ? defaultVal : [[NSUserDefaults standardUserDefaults] objectForKey:key]
#define setVal(key,val) [[NSUserDefaults standardUserDefaults] setObject:val forKey:key]; [[NSUserDefaults standardUserDefaults] synchronize]
#define ObjectForKey(dict, key, defaultVal) [dict objectForKey:key] == nil ? defaultVal : [dict objectForKey:key]


#define Segue_ShowListViewController                @"Segue_ShowListViewController"
#define Segue_ShowCongratulationViewController      @"Segue_ShowCongratulationViewController"
#define Segue_ShowGamePlayViewController            @"Segue_ShowGamePlayViewController"
#define Segue_ShowHelpViewController                @"Segue_ShowHelpViewController"
#define Segue_UnwindToPackageViewController         @"Segue_UnwindToPackageViewController"
#define Segue_UnwindToGamePlayViewController        @"Segue_UnwindToGamePlayViewController"
#define Segue_DismissGameListViewController         @"Segue_DismissGameListViewController"

#define GridSectionCount_Portrait_Min               14
#define GridSectionCount_Portrait_Max               26
#define GridSectionCount_Landscape_Min              26
#define GridSectionCount_Landscape_Max              34
#define CluesSectionCount_Min                       1
#define CluesSectionCount_Max                       3


enum {
    ACGameDifficulty_Easy = 1,
    ACGameDifficulty_Medium = 2,
    ACGameDifficulty_Hard = 3
} ACGameDifficulty;

enum {
    ACGameState_NotStarted,
    ACGameState_Started,
    ACGameState_Solved
} ACGameState;

typedef NS_OPTIONS(NSUInteger, ACLevelSortOrder) {
    ACLevelSortOrder_Sequential = 0,
    ACLevelSortOrder_Easier,
    ACLevelSortOrder_Harder,
    ACLevelSortOrder_Middle
};

typedef NS_OPTIONS(NSUInteger, ACGameControlButton) {
    ACGameControlButton_Grid = 0,
    ACGameControlButton_Key,
    ACGameControlButton_Clues
};



#endif
