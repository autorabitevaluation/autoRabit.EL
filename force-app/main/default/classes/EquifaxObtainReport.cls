global class EquifaxObtainReport extends EquifaxCalloutBase {

    @InvocableMethod(label='Obtain Equifax Credit Report' description='Obtains the Equifax Credit Report for the relationship provided in the input on behalf of the user specified.')
    global static void obtainReport(List<EquifaxCalloutInputParams> inputParams) {
        EquifaxPerformObtainReport myBatch = new EquifaxPerformObtainReport(inputParams);
        Database.executeBatch(myBatch);
    }
    
}