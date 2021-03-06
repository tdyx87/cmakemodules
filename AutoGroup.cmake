FUNCTION(strcompare src dstlist RESULT)
	SET(${RESULT} 0 PARENT_SCOPE)
	FOREACH(dst ${dstlist})
		IF(dst STREQUAL src)
			SET(${RESULT} 1 PARENT_SCOPE)
		ENDIF()
	ENDFOREACH()
ENDFUNCTION()

FUNCTION(src_auto_group root_dir base_dir RESULT)
	SET(EXCLUDEPATH "")
	set(INDEX 3)  
    while(INDEX LESS ${ARGC})  
		LIST(APPEND EXCLUDEPATH ${ARGV${INDEX}})
        math(EXPR INDEX "${INDEX} + 1")  
    endwhile()
	
	SET(subdirectoryList "")
	SET(base_dir_tmp "")
    IF (IS_DIRECTORY ${root_dir}) # 当前路径是一个目录吗，是的话就加入到包含目录
        FILE(GLOB SC_FILES "${root_dir}/*.c*" "${root_dir}/*.h*")
		LIST(APPEND subdirectoryList ${SC_FILES})
		STRING(REGEX REPLACE ".*/(.*)" "\\1" CURRENT_FOLDER ${root_dir}) 		
		IF(base_dir STREQUAL "")  #筛选器为空
			IF(CURRENT_FOLDER STREQUAL "")
			SOURCE_GROUP("" FILES ${SC_FILES})
			ELSE()
				strcompare(${CURRENT_FOLDER} "${EXCLUDEPATH}" RESULT2)
				IF(NOT ${RESULT2})
					SOURCE_GROUP(${CURRENT_FOLDER} FILES ${SC_FILES})
					LIST(APPEND base_dir_tmp ${CURRENT_FOLDER})
				ENDIF()
			ENDIF()
		ELSE()
			strcompare(${CURRENT_FOLDER} "${EXCLUDEPATH}" RESULT2)
			IF(NOT ${RESULT2})
				SOURCE_GROUP(${base_dir}\\${CURRENT_FOLDER} FILES ${SC_FILES})
				LIST(APPEND base_dir_tmp ${base_dir}\\${CURRENT_FOLDER})
			ENDIF()
		ENDIF()
    ENDIF()
	
    FILE(GLOB ALL_SUB RELATIVE ${root_dir} ${root_dir}/*) #获得当前目录下的所有文件，放入ALL_SUB列表中
    FOREACH(sub ${ALL_SUB})
        IF (IS_DIRECTORY ${root_dir}/${sub})
			strcompare(${sub} "${EXCLUDEPATH}" RESULT3)
			IF(NOT ${RESULT3})
				IF("${base_dir_tmp}" STREQUAL "")
				src_auto_group(${root_dir}/${sub} "" TEMP ${EXCLUDEPATH})
				ELSE()
				src_auto_group(${root_dir}/${sub} ${base_dir_tmp} TEMP ${EXCLUDEPATH})
				ENDIF("${base_dir_tmp}" STREQUAL "")
				LIST(APPEND subdirectoryList ${TEMP}) 
			ENDIF()
        ENDIF()
    ENDFOREACH()
	SET(${RESULT} ${subdirectoryList} PARENT_SCOPE)
ENDFUNCTION()