public class weather_extension {
	public Account acct;
    public String city {get;set;}
	public String temp {get;set;}
	public String pressure {get;set;}
	public String humidity {get;set;}
	public String temp_min {get;set;}
	public String temp_max {get;set;}
	public weather_extension(ApexPages.StandardController stdController) {
        this.acct = (Account)stdController.getRecord();
        acct = [SELECT Id, ShippingCity FROM Account WHERE Id =:acct.Id];
        String accountCity = acct.ShippingCity;
        system.debug('accountCity: '+ accountCity);
        String apiKey = '12db432ac9fb4d521185a328c7063ad9';
 
		String requestEndpoint = 'http://api.openweathermap.org/data/2.5/weather';
		requestEndpoint += '?q=' + accountCity;
		requestEndpoint += '&units=metric';
		requestEndpoint += '&APPID=' + apiKey;
		
		Http http = new Http();
		HttpRequest request = new HttpRequest();
		request.setEndpoint(requestEndpoint);
		request.setMethod('GET');
		HttpResponse response = http.send(request);
 
		// If the request is successful, parse the JSON response.
		if (response.getStatusCode() == 200) {
 
		   // Deserialize the JSON string into collections of primitive data types.
		   Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
           system.debug('results: '+ results);
		   city = String.valueOf(results.get('name'));
		   
		   Map<String, Object> mainResults = (Map<String, Object>)(results.get('main'));
		   temp = String.valueOf(mainResults.get('temp'));
            system.debug( temp);
		   pressure = String.valueOf(mainResults.get('pressure'));
			humidity = String.valueOf(mainResults.get('humidity')); 
			temp_min = String.valueOf(mainResults.get('temp_min')); 
			temp_max = String.valueOf(mainResults.get('temp_max'));
            
            acct.Temp__c = Decimal.valueOf(temp);
            //Supdate acct;
		
		} else {
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'There was an error retrieving the weather information.');
           ApexPages.addMessage(myMsg);
		}
    }
    
    @AuraEnabled
    public Static weatherObj getWeather (Id CurrentAccountId){
        weatherObj weath;
        Account acct = [SELECT Id, ShippingCity FROM Account WHERE Id =:CurrentAccountId];
        String accountCity = acct.ShippingCity;
        system.debug('accountCity: '+ accountCity);
        String apiKey = '12db432ac9fb4d521185a328c7063ad9';
		String requestEndpoint = 'http://api.openweathermap.org/data/2.5/weather';
		requestEndpoint += '?q=' + accountCity;
		requestEndpoint += '&units=metric';
		requestEndpoint += '&APPID=' + apiKey;
		
		Http http = new Http();
		HttpRequest request = new HttpRequest();
		request.setEndpoint(requestEndpoint);
		request.setMethod('GET');
		HttpResponse response = http.send(request);
 
		// If the request is successful, parse the JSON response.
		if (response.getStatusCode() == 200) {
 
		   // Deserialize the JSON string into collections of primitive data types.
		   Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
           system.debug('results: '+ results);
		   //city = String.valueOf(results.get('name'));
		   
            Map<String, Object> mainResults = (Map<String, Object>)(results.get('main'));
            weath = new weatherObj(String.valueOf(mainResults.get('temp')),
                                              String.valueOf(mainResults.get('pressure')),
                                              String.valueOf(mainResults.get('humidity')),
                                              String.valueOf(mainResults.get('temp_min')),
                                              String.valueOf(mainResults.get('temp_max')));    
        
        }
        system.debug('weath:'+ weath);
        return weath;
    }
    
    class weatherObj {
        @AuraEnabled public String temp;
        @AuraEnabled public String pressure;
        @AuraEnabled public String humidity;
        @AuraEnabled public String temp_min;
        @AuraEnabled public String temp_max;
        weatherObj(String t, String a, string l, String i, String o){
            this.temp = t;
            this.pressure=a; 
            this.humidity=l; 
            this.temp_min=i; 
            this.temp_max=o;
        }
    }
    
    
    
    //System.debug( JSON.serialize( new Cl1('anAction', 10, new List<Integer>{10, 12, 15}, new Cl2('myObj'))));
}