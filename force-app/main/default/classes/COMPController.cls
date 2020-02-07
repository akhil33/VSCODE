public class COMPController {

public String finalVariable;
    
   public void setFinalVariable (String fv) {
      finalVariable = fv;
   }
   
   public String getTipoPessoa() {
      return finalVariable;
  } 


	public COMPController (){
   ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'Value of my finalVariable:  ' + finalVariable));
}
}