global class FisChexObtainReport extends FisChexCalloutBase {

    @InvocableMethod(label='Obtain ChexSystems Report' description='Obtains the ChexSystems Report for the relationship provided in the input on behalf of the user specified.')
    global static void obtainReport(List<FisChexCalloutInputParams> inputParams) {
        FisChexPerformObtainReport myBatch = new FisChexPerformObtainReport(inputParams);
        Database.executeBatch(myBatch);
    }
}