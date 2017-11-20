Class IHEStat.Base Extends (%Persistent, %XML.Adaptor)
{

Property Code As %String(MAXLEN = "") [ Required ];

Property Description As %String(MAXLEN = "") [ Required ];

Index CodeIndex On Code;

ClassMethod OpenByCode(pCode As %String, Output pObj As %Persistent = "") As %Status
{
	Set tSC = $System.Status.OK()
	Try
	{
		Set oRS = ##class(%ResultSet).%New()
		
		// This works because the classes are all one package deep:
		Set tSC = oRS.Prepare("select %ID from "_..%ClassName(1)_" where Code=?")
		Quit:$System.Status.IsError(tSC)
		
		Set tSC=oRS.Execute(pCode)
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

ClassMethod CreateOrUpdate(pCode As %String, pDescription As %String, Output pObj As %Persistent) As %Status
{
	Set tSC = $System.Status.OK()
	Set pObj=""
	Try
	{
		Set tSC = ..OpenByCode(pCode, .pObj)
		Quit:$System.Status.IsError(tSC)
		
		If '$IsObject(pObj)
		{
			Set pObj = ..%New()
			Set pObj.Code=pCode
		}	
		
		If pDescription'=""
		{
			If $ZISWIDE(pDescription)
			{
				If pObj.Description'=pCode Set pObj.Description=pCode
			}
			Else
			{
				If pObj.Description'=pDescription Set pObj.Description=$TR(pDescription,$C(13,10,9)," ")
			}
		}		
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

Storage Default
{
<Data name="BaseDefaultData">
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
<DataLocation>^IHEStat.BaseD</DataLocation>
<DefaultData>BaseDefaultData</DefaultData>
<ExtentSize>100000</ExtentSize>
<IdLocation>^IHEStat.BaseD</IdLocation>
<IndexLocation>^IHEStat.BaseI</IndexLocation>
<StreamLocation>^IHEStat.BaseS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}
