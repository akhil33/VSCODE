global class BAT_FSCextract implements Database.Batchable<sObject>, Database.Stateful {
    public String query;  
    global String objRowStr; 
    global String attachmentHeader;
    global List<String> csvRowValues = new List<String>();

    global BAT_FSCextract (String query){
        this.query = query;
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
   
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        system.debug('scope: '+ scope);
        //Retrieved Records from the FieldPermissions (order: Name, Sobject Type, PermissionsRead, PermissionsEdit)
        //
        List<permissionset > PS = [SELECT Id,PermissionSet.Profile.Name FROM permissionset WHERE IsOwnedByProfile = true];
        Map <Id, String> PsToProfileNameMap = New Map<Id, String>();
        For(permissionset ps_Var: PS){
            PsToProfileNameMap.put(ps_Var.Id, ps_Var.Profile.Name);
        }
        
        for(FieldPermissions  currFieldPermissions : (List<FieldPermissions >) scope){
            String ProfileName = PsToProfileNameMap.get(currFieldPermissions.ParentId);
            String Fieldfull = currFieldPermissions.Field;
            
            //this will fail reporting a size of 0
            string[] Field;
            Field = Fieldfull.split('\\.');
            System.DEBUG(Field[1]);
            String SObjectType = currFieldPermissions.SObjectType;
            Boolean PermissionsRead = currFieldPermissions.PermissionsRead;
            Boolean PermissionsEdit  = currFieldPermissions.PermissionsEdit;
            //objRowStr = '' + ',' + '' + ',' + ProfileName + '' + ',';
            String rowStr = ProfileName+ ','+Field[1] + ',' + SObjectType + ',' + PermissionsRead + ',' + PermissionsEdit;
            csvRowValues.add(rowStr);
        }
        system.debug('csvRowValues:'+ csvRowValues);
    }
   
    global void finish(Database.BatchableContext BC){
        List<Folder> folders = [SELECT Id, Name FROM Folder WHERE Name = 'FSC_logs'];
       	System.debug('folders: '+ folders);
        if(!folders.isEmpty()){
            String documentName = 'FieldLevel Security-'+ Datetime.now().format('MMM') + Datetime.now().year();
            attachmentHeader = 'Profile, FieldName, Object Name, Read, Edit\n';
            //String csvFile = objRowStr + String.join(csvRowValues,'\n') +attachmentHeader + String.join(csvRowValues,'\n');
            String csvFile = attachmentHeader + String.join(csvRowValues,'\n');
           	system.debug('csvFile: '+ csvFile);
            // Insert the generated CSV file in Document object under "FSC_logs".
            Document doc = new Document(Name = documentName, 
                                        Body = Blob.valueOf(csvFile), 
                                        FolderId = folders[0].Id, 
                                        Type = 'csv', 
                                        ContentType='application/vnd.ms-excel'
                                       );
            insert doc;
        }
    }
}