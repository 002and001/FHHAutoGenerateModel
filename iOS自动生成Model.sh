#!/bin/bash
inputFilePath="/Users/a002/Desktop/Shell/iOS自动生成Model脚本/iOS自动生成Model/iOSModelTemplate.txt"
outputFilePath="/Users/a002/Desktop/Shell/iOS自动生成Model脚本/iOS自动生成Model"
inputFileContent=$(cat $inputFilePath)
properties=""
projectName="uschool"
userName="hefanghui"
createDate=`date +%Y/%m/%d`
currentYear="`date +%Y`年"
organization="topglobaledu"
hFileDefineClassOCCode=""
mFileImportClassOCCode=""
propertyType=""
memoryStragegy=""
mFileSetUnDefineKeyMethodOCCode=""
function getCalssNameFromFileContent() {
	index=0
	while read line
	do
		index=$[$index+1]	
		if [[ index=1 ]]; then
			lineContent="$line"
			OLD_IFS="$IFS"
			IFS="|"
			array=($lineContent)
			IFS="$OLD_IFS"
			replace=""
			fileCalssName="${array[1]}"
			echo "$fileCalssName"
			break
		fi
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
	# echo "memoryStragegy:$memoryStragegy"
	# echo "propertyType:$propertyType"
}

function sethFileDefineClassOCCodeWithPropertyType() {
	systemStrongMemoryStragegyPropertyTypes="NSArray|NSMutableArray|NSDictionary|NSMutableDictionary|NSSet|NSMutableSet"
	templateIndex=0
	if [[ "$memoryStragegy" = "strong" ]]; then
		if [[ "$systemStrongMemoryStragegyPropertyTypes" =~ "$1" ]]; then
			echo "$1不需定义为Class"		
		else		
			if [[ templateIndex -eq 0 ]]; then
				hFileDefineClassOCCode="@class $1;"			
			else
				hFileDefineClassOCCode="$hFileDefineClassOCCode\n@class $1;"	
			fi				
			templateIndex=$[$templateIndex+1]
		fi
	fi
}

function setmFileImportClassOCCodeWithPropertyType() {
	systemStrongMemoryStragegyPropertyTypes="NSArray|NSMutableArray|NSDictionary|NSMutableDictionary|NSSet|NSMutableSet"
	templateIndex=0
	if [[ "$memoryStragegy" = "strong" ]]; then
		if [[ "$systemStrongMemoryStragegyPropertyTypes" =~ "$1" ]]; then
			echo "$1不需定义为Class"		
		else		
			if [[ templateIndex -eq 0 ]]; then
				mFileImportClassOCCode="#import \"$1.h\""
			else
				mFileImportClassOCCode="$mFileImportClassOCCode\n#import \"$1.h\""	
			fi				
			templateIndex=$[$templateIndex+1]
		fi
	fi
}

function setPropertiesFromFileContent() {	
	index=0
	while read line || [[ -n ${line} ]]
	do		
		if [[ $index -ne 0 ]]; then
			lineContent="$line"
			OLD_IFS="$IFS"
			IFS="|"
			array=($lineContent)
			IFS="$OLD_IFS"
			replace=""					
			space=" "
			replaceStr=""
			propertyType="${array[1]}"		
			# echo "propertyType:$propertyType"
			# propertyType=$(setMemoryStragegyWithPropertyType "$propertyType")
			setMemoryStragegyWithPropertyType "$propertyType"
			sethFileDefineClassOCCodeWithPropertyType "$propertyType"
			setmFileImportClassOCCodeWithPropertyType "$propertyType"
			# echo "propertyType:$propertyType"	
			property="${array[2]}"
			IFS=":"
			propertyArray=($property)
			IFS="$OLD_IFS"
			propertyName="${propertyArray[0]}"
			if [[ "$memoryStragegy" = "assign" ]]; then
				propertyOCCode="@property (nonatomic, $memoryStragegy) $propertyType $propertyName;"
			else
				propertyOCCode="@property (nonatomic, $memoryStragegy) $propertyType *$propertyName;"
			fi			
			properties="$properties\n$propertyOCCode"
			lineContent=${lineContent/$propertyPre/$replace}
			# echo "$lineContent"
			# echo "$propertyOCCode"
		fi
		
		index=$[$index+1]
		
	done < "$inputFilePath"
	# echo "$properties"
}

function mFileSetUnDefineKeyMethod() {
	index=0
	methodBody=""
	method=""
	while read line || [[ -n ${line} ]]
	do		
		if [[ $index -ne 0 ]]; then
			# echo "$index"
			lineContent="$line"
			OLD_IFS="$IFS"
			IFS="|"
			array=($lineContent)			
			property="${array[2]}"
			IFS=":"
			propertyArray=($property)
			IFS="$OLD_IFS"
			propertyName="${propertyArray[0]}"
			propertyNameKey="${propertyArray[1]}"
			propertyArrayLength=${#propertyArray[@]}
			# echo "propertyArrayLength:$propertyArrayLength"
			if [[ propertyArrayLength -gt 1 ]]; then
				currentMappingOCCode="\tif ([key isEqualToString:@\"$propertyNameKey\"]) {\n\t\t_$propertyName = value;\n\t}"
				methodBody="$methodBody\n$currentMappingOCCode"	
			fi
			
			# echo "propertyNameKey:$propertyNameKey"			
		fi
		index=$[$index+1]	
	done < "$inputFilePath"
	mFileSetUnDefineKeyMethodOCCode="- (void)setValue:(id)value forUndefinedKey:(NSString *)key {	$methodBody\n}"
	# echo "$methodBody"
	# echo "$method"

}

className=$(getCalssNameFromFileContent)

# echo "className:$className"


# echo "$inputFileContent"
# echo "className:$className"

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

setPropertiesFromFileContent ""
mFileSetUnDefineKeyMethod ""
# properties=$(setPropertiesFromFileContent)
# mFileSetUnDefineKeyMethodContent=$(mFileSetUnDefineKeyMethod)
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

# echo "$hFileHeaderAnnotation"
# echo "$mFileHeaderAnnotation"
# echo "$hFileContent"
# echo "$mFileContent"
# mFileSetUnDefineKeyMethod ""
# outputFile="$outputFilePath/className.h"
# echo "outputFile:$outputFile"
echo "$hFileContent" > "$outputFilePath/$className.h"
echo "$mFileContent" > "$outputFilePath/$className.m"
# setPropertiesFromFileContent ""
# getCalssNameFromFileContent ""
# echo "$mFileHeader"
