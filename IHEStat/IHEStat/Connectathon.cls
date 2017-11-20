Class IHEStat.Connectathon Extends (%Persistent, IHEStat.Base)
{

Relationship SuccessfulTests As IHEStat.SuccessfulTest [ Cardinality = many, Inverse = Connectathon ];

Property ConnectathonYear As %Date;

ClassMethod CreateOrUpdate(pCode As %String, pDescription As %String, Output pObj As %Persistent) As %Status
{
	Set tSC = $System.Status.OK()
	Set pObj=""
	Try
	{
		Set tSC = ##super(pCode, pDescription,  .pObj)
		Quit:$System.Status.IsError(tSC)
		
		Write !,pObj.ConnectathonYear
		Set pObj.ConnectathonYear = ..ParseYearOutOfDescription(pDescription)
		Set tSC = pObj.%Save()
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

ClassMethod ParseYearOutOfDescription(pDescription As %String) As %Date
{
	For i=1:1:$Length(pDescription)
	{
		Set tYear = $Extract(pDescription, i, i+3)
		Quit:tYear?4N
	}
	
	If tYear?4N
	{
		Quit $ZDateH(tYear_"-01-01",3)
	}
	
	Quit ""
}

Storage Default
{
<Data name="ConnectathonDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Code</Value>
</Value>
<Value name="3">
<Value>Description</Value>
</Value>
<Value name="4">
<Value>ConnectathonYear</Value>
</Value>
</Data>
<DataLocation>^IHEStat.ConnectathonD</DataLocation>
<DefaultData>ConnectathonDefaultData</DefaultData>
<IdLocation>^IHEStat.ConnectathonD</IdLocation>
<IndexLocation>^IHEStat.ConnectathonI</IndexLocation>
<StreamLocation>^IHEStat.ConnectathonS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}
