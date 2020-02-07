public class HDL_FSCextract {
    Public static Set<String> fieldNameSet = New Set<String>();
    
    public static Map<String, Map<String, String>> generateProfileMap (List<sObject> batInput, Map <Id, String>psTopfMap){
        
        Map<String, Map<String, String>> profToFieldMap = New Map<String, Map<String, String>>();
        
        //1. Map Object using the profile name
        Map<String, List<FieldPermissions>> profNameToObjects = new  Map<String, List<FieldPermissions>>();
        For(FieldPermissions fp_var : (List<FieldPermissions>)batInput){
            if (profNameToObjects.containsKey(psTopfMap.get(fp_var.ParentId))){
                list<FieldPermissions> fpList = profNameToObjects.get(psTopfMap.get(fp_var.ParentId));
                fpList.add(fp_var);
                profNameToObjects.put(psTopfMap.get(fp_var.ParentId), fpList);
            }
            else{
                list<FieldPermissions> fpList = New list<FieldPermissions>();
                fpList.add(fp_var);
                profNameToObjects.put(psTopfMap.get(fp_var.ParentId), fpList);
            }
        }
        
        //2. parse through each key and make map of fieldname and values as inner map
        For(String profName_var : profNameToObjects.keyset()){
            if(profName_var != NULL){
                Map<String, String> fieldToPerMap = new Map<String, String>();
                List<FieldPermissions> fsc_prof = profNameToObjects.get(profName_var);
                for(FieldPermissions fp_var: fsc_prof){
                    string[] Field;
                    Field = fp_var.Field.split('\\.');
                    fieldToPerMap.put(Field[1], fp_var.PermissionsRead + ',' + fp_var.PermissionsEdit);
                    fieldNameSet.add(Field[1]);
                }
                profToFieldMap.put(profName_var, fieldToPerMap);
            }
            
        }
        //system.debug('profToFieldMap: '+ profToFieldMap);
        system.debug('AR Community Profile: '+ profToFieldMap.get('AR Community Profile'));
        //system.debug('fieldNameSet: '+ fieldNameSet);
        
        return profToFieldMap;
    }
    
    public static String generateCsvMainString (Map <String,Map<String, String>> generateProfileMap, Set<String> fieldNameSet){
        List<String> timeList = new List<String>(fieldNameSet);
        timeList.sort();
        
        List<String> csvStringList = New List<String>();
        //create row3 with field name, edit and name for each profile
        for (String profName_var1 : generateProfileMap.keySet()){
            
        }
        for(String fd: timeList){
            String finalCsvString;
            
            //field Name
            String firstCol = fd;
            
            //field value for all profiles in one row
            String lastcol= '';
            for (String profName_var1 : generateProfileMap.keySet()){
                if(generateProfileMap.containsKey(profName_var1)){
                    Map<String, String> fieldMap_var = generateProfileMap.get(profName_var1);
                    if(fieldMap_var.containsKey(fd)){
                         lastcol = lastcol+fieldMap_var.get(fd)+',';
                    }
                    else{
                        lastcol = lastcol+ ''+','+''+',';
                    }
                   
                }
            }
            finalCsvString = firstCol + ','+ lastcol;
            csvStringList.add(finalCsvString);
        }
        //System.debug('csvStringList: '+ csvStringList);
        String fullString = String.join(csvStringList,'\n');
        //system.debug('fullString: '+ fullString);
        return fullString;
    }
    
    public static String generateFinalString (Set<String> ProfileNames,String mainString){
        
        String  fullStringcsv = '';
        String header1_prefix = ''+',';
        String header_Main = '';
        List<String> profSorted = new List<String>(ProfileNames);
        profSorted.sort();
        for(String profName : profSorted){
            header_Main = header_Main + '' + ',' + profName+'' + ',';
        }
        String header1_Final = header1_prefix + header_Main + '\n';
        
        
        List<String> stringsToadd = New List<String>();
        String header_2 = 'FieldName,';
        String header2_Main = '';
        String header2_final = '';
        //multiply with number profile in the set profileNames
        for (integer i=0; i<ProfileNames.size(); i++){
            stringsToadd.add('Read,Edit');
        }
        
        
        String fullString2 = String.join(stringsToadd,',');
        header2_final = header_2+ fullString2 + '\n';
        
        
        fullStringcsv = header1_Final + header2_final + mainString;
        system.debug('fullStringcsv: '+ fullStringcsv);
        return fullStringcsv;
    }
}