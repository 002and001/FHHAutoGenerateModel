#!/bin/bash
inputFilePath="/Users/a002/PrivateRepository/FHHAutoGenerateModel/iOS自动生成Model/iOSModelTemplate.txt"
outputFilePath="/Users/a002/PrivateRepository/FHHAutoGenerateModel/iOS自动生成Model/"
inputFileContent=$(cat $inputFilePath)
projectName="uschool"
userName="hefanghui"
createDate=`date +%Y/%m/%d`
currentYear="`date +%Y`年"
organization="topglobaledu"
properties=""
hFileDefineClassOCCode=""
mFileImportClassOCCode=""
propertyType=""
memoryStragegy=""
mFileSetUnDefineKeyMethodOCCode=""
mFileYYModelMethodOCCode=""
mFileMJExtentionMethodOCCode=""
className=""

function setCalssName() {
	index=0
	while read line
	do
		index=$[$index+1]	
		if [[ $index -eq 2 ]]; then
			lineContent="$line"
			OLD_IFS="$IFS"
			IFS="["
			array=($lineContent)
			IFS="$OLD_IFS"
			className="${array[1]}"
			className=${className/"]"/""}			
			break
		fi
	done < "$inputFilePath"
}

function sethFileDefineClassOCCodeWithPropertyTypeIfNeeded() {
	index=0
	while read line || [[ -n ${line} ]]
	do				
		if [[ $index -gt 1 ]]; then
			lineContent="$line"
			OLD_IFS="$IFS"
			IFS="["
			array=($lineContent)			
			propertyContent="${array[1]}"	
			IFS="|"	
			propertyContentArray=($propertyContent)
			propertyType="${propertyContentArray[0]}"
			IFS="$OLD_IFS"
			setMemoryStragegyWithPropertyType "$propertyType"
			sethFileDefineClassOCCodeWithPropertyType "$propertyType"			
		fi		
		index=$[$index+1]
	done < "$inputFilePath"
}

function setMemoryStragegyWithPropertyType() {
	assignMemoryStragegyPropertyTypes="NSInteger|NSUInteger|CGFloat|BOOL"
	copyMemoryStragegyPropertyTypes="NSString"
	if [[ "$assignMemoryStragegyPropertyTypes" =~ "$1" ]]; then
		memoryStragegy="assign"
	elif [[ "$copyMemoryStragegyPropertyTypes" =~ "$1" ]]; then
		memoryStragegy="copy"
	else
		memoryStragegy="strong"
	fi
}

function sethFileDefineClassOCCodeWithPropertyType() {
	systemStrongMemoryStragegyPropertyTypes="NSArray|NSMutableArray|NSDictionary|NSMutableDictionary|NSSet|NSMutableSet"
	if [[ "$memoryStragegy" = "strong" ]]; then
		if [[ "$systemStrongMemoryStragegyPropertyTypes" =~ "$1" ]]; then
			# echo "$1不需定义为Class"
			echo ""
		else		
			if [[ "$hFileDefineClassOCCode" = "" ]]; then
				hFileDefineClassOCCode="@class $1;"						
			else
				hFileDefineClassOCCode="$hFileDefineClassOCCode\n@class $1;"			
			fi							
		fi		
	fi
}

function setProperties() {	
	index=0
	while read line || [[ -n ${line} ]]
	do		
		if [[ $index -gt 1 ]]; then
			lineContent="$line"
			OLD_IFS="$IFS"
			IFS="["
			array=($lineContent)			
			replace=""					
			array1="${array[1]}"	
			IFS="|"	
			array2=($array1)
			IFS="$OLD_IFS"
			propertyType="${array2[0]}"
			setMemoryStragegyWithPropertyType "$propertyType"
			property="${array2[1]}"
			IFS=":"
			propertyArray=($property)
			IFS="$OLD_IFS"
			propertyName="${propertyArray[0]}"
			if [[ "$memoryStragegy" = "assign" ]]; then
				propertyOCCode="@property (nonatomic, $memoryStragegy) $propertyType $propertyName;"
			else
				propertyOCCode="@property (nonatomic, $memoryStragegy) $propertyType *$propertyName;"
			fi						
			propertyOCCode=${propertyOCCode/"]"/""}
			properties="$properties\n$propertyOCCode"			
			lineContent=${lineContent/$propertyPre/$replace}
		fi		
		index=$[$index+1]		
	done < "$inputFilePath"
}

function setmFileImportClassOCCodeWithPropertyType() {
	systemStrongMemoryStragegyPropertyTypes="NSArray|NSMutableArray|NSDictionary|NSMutableDictionary|NSSet|NSMutableSet"
	if [[ "$memoryStragegy" = "strong" ]]; then		
		if [[ "$systemStrongMemoryStragegyPropertyTypes" =~ "$1" ]]; then
			# echo "$1不需定义为Class"
			echo ""
		else		
			# echo "$1"
			if [[ $mFileImportClassOCCode = "" ]]; then
				mFileImportClassOCCode="#import \"$1.h\""
			else
				mFileImportClassOCCode="$mFileImportClassOCCode\n#import \"$1.h\""	
			fi				
		fi
	fi
}

function setmFileImportClassOCCodeWithPropertyTypeIfNeeded() {
	index=0
	while read line || [[ -n ${line} ]]
	do		
		if [[ $index -gt 1 ]]; then
			lineContent="$line"
			OLD_IFS="$IFS"
			IFS="["
			array=($lineContent)
			array1="${array[1]}"	
			IFS="|"	
			array2=($array1)
			IFS="$OLD_IFS"
			propertyType="${array2[0]}"
			setMemoryStragegyWithPropertyType "$propertyType"
			setmFileImportClassOCCodeWithPropertyType "$propertyType"
		fi
		index=$[$index+1]		
	done < "$inputFilePath"
}

function setmFileSetUnDefineKeyMethod() {
	lineIndex=0
	undefinekeyIndex=0
	methodBody=""
	method=""

	while read line || [[ -n ${line} ]]
	do		
		if [[ $lineIndex -gt 1 ]]; then
			lineContent="$line"
			OLD_IFS="$IFS"
			IFS="["
			array=($lineContent)							
			array1="${array[1]}"	
			IFS="|"	
			array2=($array1)
			IFS="$OLD_IFS"
			propertyType="${array2[0]}"		
			setMemoryStragegyWithPropertyType "$propertyType"
			property="${array2[1]}"
			IFS=":"
			propertyArray=($property)
			IFS="$OLD_IFS"
			propertyName="${propertyArray[0]}"
			propertyNameKey="${propertyArray[1]}"
			propertyName=${propertyName/"]"/""}
			propertyNameKey=${propertyNameKey/"]"/""}
			propertyArrayLength=${#propertyArray[@]}
			if [[ $propertyArrayLength -gt 1 ]]; then
				if [[ $undefinekeyIndex -eq 0 ]]; then
					currentMappingOCCode="\tif ([key isEqualToString:@\"$propertyNameKey\"]) {\n\t\t_$propertyName = value;\n\t}"	
					methodBody="$methodBody\n$currentMappingOCCode"					
				else
					currentMappingOCCode=" else if ([key isEqualToString:@\"$propertyNameKey\"]) {\n\t\t_$propertyName = value;\n\t}"
					methodBody="$methodBody$currentMappingOCCode"
				fi	
							
				undefinekeyIndex=$[$undefinekeyIndex+1]
			fi
		fi
		lineIndex=$[$lineIndex+1]	
	done < "$inputFilePath"
	mFileSetUnDefineKeyMethodOCCode="- (void)setValue:(id)value forUndefinedKey:(NSString *)key {	$methodBody\n}"
}

setCalssName ""
setmFileImportClassOCCodeWithPropertyTypeIfNeeded ""
setProperties ""
sethFileDefineClassOCCodeWithPropertyTypeIfNeeded ""
setmFileSetUnDefineKeyMethod ""

hFileHeaderAnnotation="//
//  $className.h
//  $projectName
//
//  Created by $userName on $createDate.
//  Copyright © $currentYear $organization. All rights reserved.
//"

mFileHeaderAnnotation="//  ************************************************************************
//
//  $className.m
//  $projectName
//
//  Created by $userName on $createDate.
//  Copyright © $currentYear $organization. All rights reserved.
//
//  Main function:
//
//  Other specifications:
//
//  ************************************************************************"

initMethod="- (instancetype)initWithDictionary:(NSDictionary *)dictionary;"
hFileContent="$hFileHeaderAnnotation\n
#import <Foundation/Foundation.h>
$hFileDefineClassOCCode\n
@interface $className : NSObject
$properties

$initMethod\n
@end
"

mFileContent="$mFileHeaderAnnotation\n
#import \"$className.h\"
$mFileImportClassOCCode\n
@implementation $className

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
	if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dictionary];
    }
    return self;	
}

$mFileSetUnDefineKeyMethodOCCode

@end
"

echo "$hFileContent" > "$outputFilePath/$className.h"
echo "$mFileContent" > "$outputFilePath/$className.m"
