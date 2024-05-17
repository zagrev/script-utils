#!/bin/bash

# Check if .clang-format already exists in repo

if [ -f .clang-format ]; then
    echo "Using .clang-format present in the branch in format-all"
    has_custom_style=true
else
    #insert heredocs .clang generation

cat << "EOF" > ./.clang-format
---
# Put in your home directory as ".clang-format". This syntax:
# https://releases.llvm.org/6.0.1/tools/clang/docs/ClangFormatStyleOptions.html
Language: Cpp
# BasedOnStyle:  LLVM
AccessModifierOffset: -4
AlignAfterOpenBracket: Align
AlignConsecutiveAssignments: None
AlignConsecutiveDeclarations: None
AlignEscapedNewlines: Left
AlignOperands: Align
AlignTrailingComments: true
AllowAllParametersOfDeclarationOnNextLine: true
AllowShortBlocksOnASingleLine: Empty
AllowShortCaseLabelsOnASingleLine: true
AllowShortEnumsOnASingleLine: true
AllowShortFunctionsOnASingleLine: Empty
AllowShortIfStatementsOnASingleLine: Never
AllowShortLambdasOnASingleLine: All
AllowShortLoopsOnASingleLine: false
AlwaysBreakAfterDefinitionReturnType: None
AlwaysBreakAfterReturnType: None
AlwaysBreakBeforeMultilineStrings: false
AlwaysBreakTemplateDeclarations: Yes
BinPackArguments: false
BinPackParameters: false
BraceWrapping:
  AfterClass: true
  AfterEnum: true
  AfterFunction: true
  AfterNamespace: true
  AfterObjCDeclaration: true
  AfterStruct: true
  AfterUnion: true
  BeforeCatch: true
  BeforeElse: true
  IndentBraces: false
  SplitEmptyFunction: true
  SplitEmptyRecord: true
  SplitEmptyNamespace: true
BreakBeforeBinaryOperators: NonAssignment
BreakBeforeBraces: Allman
BreakBeforeInheritanceComma: false
BreakBeforeTernaryOperators: true
BreakConstructorInitializersBeforeComma: false
BreakConstructorInitializers: BeforeColon
BreakAfterJavaFieldAnnotations: false
BreakStringLiterals: true
ColumnLimit: 120
CommentPragmas: '^ IWYU pragma:'
CompactNamespaces: false
ConstructorInitializerAllOnOneLineOrOnePerLine: true
ConstructorInitializerIndentWidth: 4
ContinuationIndentWidth: 4
Cpp11BracedListStyle: true
DerivePointerAlignment: false
DisableFormat: false
ExperimentalAutoDetectBinPacking: false
FixNamespaceComments: true
ForEachMacros:
  - foreach
  - Q_FOREACH
  - BOOST_FOREACH
IncludeCategories:
  - Regex: '^"(llvm|llvm-c|clang|clang-c)/'
    Priority: 2
  - Regex: '^(<|"(gtest|gmock|isl|json)/)'
    Priority: 3
  - Regex: '.*'
    Priority: 1
IncludeIsMainRegex: '(Test)?$'
IndentCaseLabels: false
IndentWidth: 4
IndentWrappedFunctionNames: true
InsertBraces: true
JavaScriptQuotes: Leave
JavaScriptWrapImports: true
KeepEmptyLinesAtTheStartOfBlocks: false
MacroBlockBegin: ''
MacroBlockEnd: ''
MaxEmptyLinesToKeep: 1
NamespaceIndentation: None
ObjCBlockIndentWidth: 4
ObjCSpaceAfterProperty: false
ObjCSpaceBeforeProtocolList: true
PenaltyBreakAssignment: 2
PenaltyBreakBeforeFirstCallParameter: 19
PenaltyBreakComment: 300
PenaltyBreakFirstLessLess: 120
PenaltyBreakString: 1000
PenaltyExcessCharacter: 1000000
PenaltyReturnTypeOnItsOwnLine: 60
PointerAlignment: Left
ReferenceAlignment: Left
ReflowComments: true
SortIncludes: Never
SortUsingDeclarations: true
SpaceAfterCStyleCast: false
SpaceAfterTemplateKeyword: true
SpaceBeforeAssignmentOperators: true
SpaceBeforeParens: ControlStatements
SpaceInEmptyParentheses: false
SpacesBeforeTrailingComments: 1
SpacesInAngles: false
SpacesInContainerLiterals: true
SpacesInCStyleCastParentheses: false
SpacesInParentheses: false
SpacesInSquareBrackets: false
Standard: c++20
TabWidth: 4
UseTab: Never
...
EOF


    has_custom_style=false
fi

# Get list of git submodules to ignore in format "submodule1|submodule2|...|"
if [ -f .gitmodules ]; then
    ignore="$(grep path .gitmodules | sed 's/.*= //' | sed -z 's/\n/ /g' | sed -e 's/\s/\/|/g')"
fi

# Get a list of other directories to be ignored (if specified) in same format as submodules
# .format_ignore.txt must be formatted like:
# path = path/to/ignore
# path = some/other/path/*.txt
if [ -f .format_ignore.txt ]; then
    other_format_ignore="$(grep path .format_ignore.txt | sed 's/.*= //' | sed -z 's/\n/ /g' | sed -e 's/ /|/g')"
    echo "Also ignoring ${other_format_ignore} as specified in the .format_ignore"
    ignore="${ignore}${other_format_ignore}"
fi

# Submodules above are delimited by '|' (including trailing char). Add build folder.
ignore="${ignore}build/"
echo "Directories to ignore: $ignore"

# Generate files list
fileList=$(find . -type f \( -iname '*.cpp' -o -iname '*.c' -o -iname '*.hpp' -o -iname '*.h' \) | grep -vE "$ignore")

if [ -n "$fileList" ]; then
    # Convert fileList to array for shellcheck
    fileList=$(echo "$fileList" | tr -s '\n' ' ')
    IFS=" " read -r -a fileListArr <<< "$fileList"

    # Run clang-format
    clang-format -style=file -verbose -i "${fileListArr[@]}"

    echo "Files formatted successfully"
fi

# Cleanup style file if copied from DevOps
if [ "$has_custom_style" = false ]; then
    rm .clang-format
fi
