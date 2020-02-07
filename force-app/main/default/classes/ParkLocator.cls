public without sharing class ParkLocator
{
    
    public static List<string> country(string strCountryName)
    {
        ParkService.ParksImplPort objParkService = new ParkService.ParksImplPort ();
        //objParkService.ParksImplPort  objInner = new ParksImplPort.ParksImplPort();
        List<string> lstCountry = objParkService.byCountry(strCountryName);
        return lstCountry ;
    }
    public void did()
    {
        string theCountry='India';
        //  gt=theCountry;
        parkService.ParksImplPort park = new parkService.ParksImplPort();
        park.byCountry(theCountry);
        ParkService.byCountryResponse response_x= new ParkService.byCountryResponse(); 
        
        
        
    }
    
}