#!/bin/bash
inputFilePath="/Users/a002/PrivateRepository/FHHAutoGenerateModel/iOS自动生成Model/iOSModelTemplate.txt"
outputFilePath="/Users/a002/PrivateRepository/FHHAutoGenerateModel/iOS自动生成Model/"
inputFileContent=$(cat $inputFilePath)
projectName="uschool"
userName="hefanghui"
createDate=`date +%Y/%m/%d`
currentYear="`date +%Y`年"
organization="topglobaledu"
className=""
configurationContent=""
properties=""
hFileDefineClassOCCode=""
mFileImportClassOCCode=""
propertyType=""
memoryStragegy=""
mFileMappingMethod=""
mFileSetUnDefineKeyMethodOCCode=""
mFileModelCustomPropertyMapperOCCode=""
mFilemodelContainerPropertyGenericClassOCCode=""
mFileMJReplacedKeyFromPropertyNameOCCode=""
mFileMJObjectClassInArrayOCCode=""

function setConfigurationContent() {
	index=0
	while read line
	do		
		if [[ $index -eq 0 ]]; then
			lineContent="$line"
			OLD_IFS="$IFS"
			IFS="["
			array=($lineContent)
			IFS="$OLD_IFS"
			configurationContent="${array[1]}"
			configurationContent=${configurationContent/"]"/""}			
			break
		fi
		index=$[$index+1]
	done < "$inputFilePath"
}

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

function setmFileMappingKeyMethodsIfNeeded() {
	lineIndex=0
	undefinekeyIndex=0
	systemUndefineKeyMethodBody=""
	yyModelMappingKeyMethodBody=""
	yyModelGenericClassBody=""
	mJExtentionMappingKeyMethodBody=""
	mJExtentionGenericClassBody=""

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
			# echo "memoryStragegy:$memoryStragegy"
			property="${array2[1]}"
			IFS=":"
			propertyArray=($property)
			IFS="$OLD_IFS"
			propertyName="${propertyArray[0]}"
			propertyNameKey="${propertyArray[1]}"
			propertyName=${propertyName/"]"/""}
			propertyNameKey=${propertyNameKey/"]"/""}
			propertyArrayLength=${#propertyArray[@]}	
			# echo "propertyName:$propertyName"
			if [[ $propertyArrayLength -gt 1 ]]; then
				setmFileSetUnDefineKeyMethodIfNeeded "$propertyNameKey" "$propertyName"
				setmFileYYModelMappingMethodIfNeeded "$propertyNameKey" "$propertyName"
				setmFileMJExtentionReplacedKeyFromPropertyNameIfNeeded "$propertyNameKey" "$propertyName"
				undefinekeyIndex=$[$undefinekeyIndex+1]
			fi
			setmFileYYModelGenericClassBMethodIfNeeded "$propertyNameKey" "$propertyName" "$propertyArrayLength"
			setmFileMJExtentionObjectClassInArrayIfNeeded "$propertyNameKey" "$propertyName" "$propertyArrayLength"
		fi
		lineIndex=$[$lineIndex+1]	
	done < "$inputFilePath"

	lineReturn=""
	if [[ "$configurationContent" =~ "System" ]]; then
		if [[ "$systemUndefineKeyMethodBody" = "" ]]; then
			systemUndefineKeyMethodBody="\n\t// do nothing"
		fi
		mFileSetUnDefineKeyMethodOCCode="- (void)setValue:(id)value forUndefinedKey:(NSString *)key {$systemUndefineKeyMethodBody\n}"
		mFileMappingMethod="$mFileSetUnDefineKeyMethodOCCode\n"
		lineReturn="\n"
	fi
	
	if [[ "$yyModelMappingKeyMethodBody" != "" ]]; then
		yyModelMappingKeyMethodBodyLength=${#yyModelMappingKeyMethodBody}
		yyModelMappingKeyMethodBody=${yyModelMappingKeyMethodBody:0:yyModelMappingKeyMethodBodyLength-1}
		mFileModelCustomPropertyMapperOCCode="+ (NSDictionary *)modelCustomPropertyMapper {
    return @{$yyModelMappingKeyMethodBody};\n}"
    	mFileMappingMethod="$mFileMappingMethod$lineReturn$mFileModelCustomPropertyMapperOCCode\n"	
	fi

	if [[ "$yyModelGenericClassBody" != "" ]]; then
		yyModelGenericClassBodyLength=${#yyModelGenericClassBody}
		yyModelGenericClassBody=${yyModelGenericClassBody:0:yyModelGenericClassBodyLength-1}
		mFilemodelContainerPropertyGenericClassOCCode="+ (NSDictionary *)modelContainerPropertyGenericClass {
    	return @{$yyModelGenericClassBody};\n}"	
    	mFileMappingMethod="$mFileMappingMethod\n$mFilemodelContainerPropertyGenericClassOCCode\n"
	fi
	
	if [[ "$mJExtentionMappingKeyMethodBody" != "" ]]; then
		mJExtentionMappingKeyMethodBodyLength=${#mJExtentionMappingKeyMethodBody}
		mJExtentionMappingKeyMethodBody=${mJExtentionMappingKeyMethodBody:0:mJExtentionMappingKeyMethodBodyLength-1}
		mFileMJReplacedKeyFromPropertyNameOCCode="+ (NSDictionary *)replacedKeyFromPropertyName {
    return @{$mJExtentionMappingKeyMethodBody};\n}"
    	mFileMappingMethod="$mFileMappingMethod$lineReturn$mFileMJReplacedKeyFromPropertyNameOCCode\n"
	fi

	if [[ "$mJExtentionGenericClassBody" != "" ]]; then
		mJExtentionGenericClassBodyLength=${#mJExtentionGenericClassBody}
		mJExtentionGenericClassBody=${mJExtentionGenericClassBody:0:mJExtentionGenericClassBodyLength-1}
		mFileMJObjectClassInArrayOCCode="+ (NSDictionary *)objectClassInArray {
    	return @{$mJExtentionGenericClassBody};\n}"
    	mFileMappingMethod="$mFileMappingMethod\n$mFileMJObjectClassInArrayOCCode\n"
	fi		
}

function setmFileSetUnDefineKeyMethodIfNeeded() {		
	if [[ "$configurationContent" =~ "System" ]]; then
		propertyNameKey="$1"
		propertyName="$2"
		currentMappingOCCode="\tif ([key isEqualToString:@\"$propertyNameKey\"]) {\n\t\t_$propertyName = value;\n\t\treturn;\n\t}"
		systemUndefineKeyMethodBody="$systemUndefineKeyMethodBody\n$currentMappingOCCode"		
	fi		
}

function setmFileYYModelMappingMethodIfNeeded() {
	if [[ "$configurationContent" =~ "YYModel" ]]; then
		propertyNameKey="$1"
		propertyName="$2"
		currentMappingOCCode="@\"$propertyName\" : @\"$propertyNameKey\","				
		if [[ "$yyModelMappingKeyMethodBody" = "" ]]; then
			yyModelMappingKeyMethodBody="$currentMappingOCCode"	
		else
			yyModelMappingKeyMethodBody="$yyModelMappingKeyMethodBody\n\t\t\t $currentMappingOCCode"
		fi
	fi
}

function setmFileYYModelGenericClassBMethodIfNeeded() {
	if [[ "$configurationContent" =~ "YYModel" ]]; then
		propertyNameKey="$1"
		propertyName="$2"
		propertyArrayLength="$3"
		systemStrongMemoryStragegyPropertyTypes="NSArray|NSMutableArray|NSDictionary|NSMutableDictionary|NSSet|NSMutableSet"
		if [[ "$memoryStragegy" = "strong" ]]; then
			if [[ "$systemStrongMemoryStragegyPropertyTypes" =~ "$propertyType"  ]]; then
				currentGenericClass=""
			else
				currentGenericClass="@\"$propertyName\" : [$propertyType class],"
				if [[ "$yyModelGenericClassBody" = "" ]]; then
					yyModelGenericClassBody="$currentGenericClass"
				else
					yyModelGenericClassBody="$yyModelGenericClassBody\n\t\t\t\t $currentGenericClass"
				fi				
			fi
		fi
	fi
}

function setmFileMJExtentionReplacedKeyFromPropertyNameIfNeeded() {	
	if [[ "$configurationContent" =~ "MJExtention" ]]; then
		propertyNameKey="$1"
		propertyName="$2"
		currentMappingOCCode="@\"$propertyName\" : @\"$propertyNameKey\","				
		if [[ "$mJExtentionMappingKeyMethodBody" = "" ]]; then
			mJExtentionMappingKeyMethodBody="$currentMappingOCCode"	
		else
			mJExtentionMappingKeyMethodBody="$mJExtentionMappingKeyMethodBody\n\t\t\t $currentMappingOCCode"
		fi
	fi
}

function setmFileMJExtentionObjectClassInArrayIfNeeded() {
	if [[ "$configurationContent" =~ "MJExtention" ]]; then
		propertyNameKey="$1"
		propertyName="$2"
		propertyArrayLength="$3"
		systemStrongMemoryStragegyPropertyTypes="NSArray|NSMutableArray|NSDictionary|NSMutableDictionary|NSSet|NSMutableSet"
		if [[ "$memoryStragegy" = "strong" ]]; then
			if [[ "$systemStrongMemoryStragegyPropertyTypes" =~ "$propertyType"  ]]; then
				currentGenericClass=""
			else
				currentGenericClass="@\"$propertyName\" : [$propertyType class],"
				if [[ "$mJExtentionGenericClassBody" = "" ]]; then
					mJExtentionGenericClassBody="$currentGenericClass"
				else
					mJExtentionGenericClassBody="$mJExtentionGenericClassBody\n\t\t\t\t $currentGenericClass"
				fi				
			fi
		fi
	fi
}

setConfigurationContent ""
setCalssName ""
setmFileImportClassOCCodeWithPropertyTypeIfNeeded ""
setProperties ""
sethFileDefineClassOCCodeWithPropertyTypeIfNeeded ""
# setmFileSetUnDefineKeyMethod ""
setmFileMappingKeyMethodsIfNeeded ""

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

initMethodInterface=""
if [[ "$configurationContent" =~ "System" ]]; then
	initMethodInterface="\n- (instancetype)initWithDictionary:(NSDictionary *)dictionary;\n"	
fi

hFileContent="$hFileHeaderAnnotation\n
#import <Foundation/Foundation.h>
$hFileDefineClassOCCode\n
@interface $className : NSObject
$properties
$initMethodInterface
@end
"

initMethodImplement=""
if [[ "$configurationContent" =~ "System" ]]; then
	initMethodImplement="\n- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
	if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dictionary];
    }
    return self;	
}\n"	
fi

if [[ "$configurationContent" =~ "MJExtention" ]]; then
	mFileImportClassOCCode="#import \"MJExtension.h\"\n$mFileImportClassOCCode"	
fi
if [[ "$configurationContent" =~ "YYModel" ]]; then
	mFileImportClassOCCode="#import \"NSObject+YYModel.h\"\n$mFileImportClassOCCode"	
fi

mFileContent="$mFileHeaderAnnotation\n
#import \"$className.h\"
$mFileImportClassOCCode\n
@implementation $className
$initMethodImplement
$mFileMappingMethod
@end
"

echo "$hFileContent" > "$outputFilePath/$className.h"
echo "$mFileContent" > "$outputFilePath/$className.m"
