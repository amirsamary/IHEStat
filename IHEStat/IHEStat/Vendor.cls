Class IHEStat.Vendor Extends (%Persistent, IHEStat.Base)
{

Relationship Implementations As IHEStat.Implementation [ Cardinality = many, Inverse = Vendor ];

Relationship SuccessfulTests As IHEStat.SuccessfulTest [ Cardinality = many, Inverse = Vendor ];

ClassMethod OpenByDescription(pDescription As %String, Output pObj As %Persistent = "") As %Status
{
	Set tSC = $System.Status.OK()
	Try
	{
		Set oRS = ##class(%ResultSet).%New()
		
		// This works because the classes are all one package deep:
		Set tSC = oRS.Prepare("select %ID from "_..%ClassName(1)_" where Description=?")
		Quit:$System.Status.IsError(tSC)
		
		Set tSC=oRS.Execute(pDescription)
		Quit:$System.Status.IsError(tSC)
		
		If oRS.Next()
		{
			Set pObj = oRS.GetObject()
		}
	}
	Catch (tException)
	{
		If oException.%IsA("%Exception.SystemException")
		{
		    Set $zerror = oException.DisplayString()
		}

		Set tSC = oException.AsStatus()
		
		Do LOG^%ETN
	}
	
	Quit tSC
}

Storage Default
{
<Data name="VendorDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Code</Value>
</Value>
<Value name="3">
<Value>Description</Value>
</Value>
</Data>
<DataLocation>^IHEStat.VendorD</DataLocation>
<DefaultData>VendorDefaultData</DefaultData>
<ExtentSize>100000</ExtentSize>
<IdLocation>^IHEStat.VendorD</IdLocation>
<IndexLocation>^IHEStat.VendorI</IndexLocation>
<StreamLocation>^IHEStat.VendorS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}
