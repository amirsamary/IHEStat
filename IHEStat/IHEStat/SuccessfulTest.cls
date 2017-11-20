Class IHEStat.SuccessfulTest Extends %Persistent
{

Relationship Connectathon As IHEStat.Connectathon [ Cardinality = one, Inverse = SuccessfulTests, Required ];

Relationship Vendor As IHEStat.Vendor [ Cardinality = one, Inverse = SuccessfulTests, Required ];

Relationship Actor As IHEStat.Actor [ Cardinality = one, Inverse = SuccessfulTests, Required ];

Index ActorIndex On Actor;

Relationship Profile As IHEStat.Profile [ Cardinality = one, Inverse = SuccessfulTests, Required ];

Index ProfileIndex On Profile;

Index SuccessfulTestIndex On (Connectathon, Vendor, Profile, Actor) [ Unique ];

ClassMethod CreateOrUpdate(pConnectathon As Connectathon, pVendor As IHEStat.Vendor, pActor As IHEStat.Actor, pProfile As IHEStat.Profile, pObj As IHEStat.SuccessfulTest) As %Status
{
	Set tSC = $System.Status.OK()
	Try
	{
		Set tSC = ..Open(pConnectathon, pVendor, pActor, pProfile, .pObj)
		Quit:$System.Status.IsError(tSC)
				
		If '$IsObject(pObj)
		{
			Set pObj=..%New()
			Set pObj.Connectathon=pConnectathon
			Set pObj.Vendor=pVendor
			Set pObj.Actor=pActor
			Set pObj.Profile=pProfile
			Set tSC = pObj.%Save()
		}
	}
	Catch (tException)
	{
		Set tSC = tException.AsStatus()
	}
	
	Quit tSC
}

ClassMethod Open(pConnectathon As Connectathon, pVendor As IHEStat.Vendor, pActor As IHEStat.Actor, pProfile As IHEStat.Profile, pObj As IHEStat.SuccessfulTest) As %Status
{
	Set tSC = $System.Status.OK()
	Set pObj = ""
	Try
	{
		Set oRS = ##class(%ResultSet).%New()
		Set tSC = oRS.Prepare("select %ID from IHEStat.SuccessfulTest where Connectathon=? and Vendor=? and Actor=? and Profile=?")
		Quit:$System.Status.IsError(tSC)
		s ^amir2("pConnectathon")=pConnectathon
		s ^amir2("pVendor")=pVendor
		s ^amir2("pActor")=pActor.%Id()
		s ^amir2("pProfile")=pProfile
		Set tSC = oRS.Execute(pConnectathon.%Id(), pVendor.%Id(), pActor.%Id(), pProfile.%Id())
		Quit:$System.Status.IsError(tSC)
		
		If oRS.Next()
		{
			Set pObj = oRS.GetObject()
		}
	}
	Catch (tException)
	{
		Set tSC = tException.AsStatus()
	}
	
	Quit tSC
}

ClassMethod DeleteTestsForConnectathon(pConnectathonId As %String) As %Status
{
	Set tSC = $System.Status.OK()
	Try
	{
		Set oRS = ##class(%ResultSet).%New()
		Set tSC = oRS.Prepare("delete from IHEStat.SuccessfulTest where Connectathon=?")
		Quit:$System.Status.IsError(tSC)
		
		Set tSC = oRS.Execute(pConnectathonId)
		Quit:$System.Status.IsError(tSC)
	}
	Catch (tException)
	{
		Set tSC = tException.AsStatus()
	}
	
	Quit tSC
}

Storage Default
{
<Data name="SuccessfulTestDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Connectathon</Value>
</Value>
<Value name="3">
<Value>Vendor</Value>
</Value>
<Value name="4">
<Value>Actor</Value>
</Value>
<Value name="5">
<Value>Profile</Value>
</Value>
</Data>
<DataLocation>^IHEStat.SuccessfulTestD</DataLocation>
<DefaultData>SuccessfulTestDefaultData</DefaultData>
<IdLocation>^IHEStat.SuccessfulTestD</IdLocation>
<IndexLocation>^IHEStat.SuccessfulTestI</IndexLocation>
<StreamLocation>^IHEStat.SuccessfulTestS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}
