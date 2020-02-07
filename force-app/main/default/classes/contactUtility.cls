public class contactUtility {
	public static String formatphonenumber(String cphone) {
		String fphone = cphone.replaceAll('\\D','');
		if (fphone.length() == 10) {
			fphone = formatphonenum(fphone);
			return fphone;
		}else {
			return cphone;
		}
	}
	static String formatphonenum (String s) {
		s = '+1'+ '(' + s.substring(0, 3) + ') ' + s.substring(3, 6) + '-' + s.substring(6);
		return s;
	}
}