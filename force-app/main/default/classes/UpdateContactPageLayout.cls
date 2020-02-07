public class UpdateContactPageLayout {
    // Add custom field to page layout
    
    public Metadata.Layout addLayoutItem () {
        
        // Retrieve Account layout and section 
        List<Metadata.Metadata> layoutsList  = Metadata.Operations.retrieve(Metadata.MetadataType.Layout, new List<String> {'Account-Account Layout'});
        Metadata.Layout layoutMetadata  = (Metadata.Layout) layoutsList .get(0);
        Metadata.LayoutSection layoutSectionToEdit = null;
        List<Metadata.LayoutSection> contactLayoutSection  = layoutMetadata.layoutSections;
        for (Metadata.LayoutSection section : contactLayoutSection ) {
            
            if (section.label == 'Account Information') {
                layoutSectionToEdit = section;
                break;
            }
        }
        
        // Add the field under Account info section in the left column
        List<Metadata.LayoutColumn> contactColumns  = layoutSectionToEdit.layoutColumns;     
        List<Metadata.LayoutItem> contactLayoutItems  = contactColumns .get(0).layoutItems;
        
        // Create a new layout item for the custom field
        Metadata.LayoutItem item = new Metadata.LayoutItem();
        item.behavior = Metadata.UiBehavior.Edit;
        item.field = 'AMAPI__Apex_MD_API_Twitter_name__c';
        contactLayoutItems.add(item);
        
        return layoutMetadata;
    }
}