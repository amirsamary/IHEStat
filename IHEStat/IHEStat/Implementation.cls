Class IHEStat.Implementation Extends (%Persistent, %XML.Adaptor)
{

Relationship Vendor As IHEStat.Vendor [ Cardinality = one, Inverse = Implementations ];

Index VendorIndex On Vendor;

Relationship Actor As IHEStat.Actor [ Cardinality = one, Inverse = Participations ];

Index ActorIndex On Actor;

Relationship Profile As IHEStat.Profile [ Cardinality = one, Inverse = VendorImplementations ];

Index ProfileIndex On Profile;

Index ImplementationIndex On (Vendor, Profile, Actor) [ Unique ];

ClassMethod CreateOrUpdate(pVendor As IHEStat.Vendor, pActor As IHEStat.Actor, pProfile As IHEStat.Profile, pObj As IHEStat.Implementation) As %Status
{
	Set tSC = $System.Status.OK()
	Try
	{
		Set tSC = ..Open(pVendor, pActor, pProfile, .pObj)
		Quit:$System.Status.IsError(tSC)
				
		If '$IsObject(pObj)
		{
			Set pObj=..%New()
			Set pObj.Vendor=pVendor
			Set pObj.Actor=pActor
			Set pObj.Profile=pProfile
			Set pObj.Actor.Profile=pProfile
			Set tSC = pObj.%Save()
		}
	}
	Catch (tException)
	{
		Set tSC = tException.AsStatus()
	}
	
	Quit tSC
}

ClassMethod Open(pVendor As IHEStat.Vendor, pActor As IHEStat.Actor, pProfile As IHEStat.Profile, pObj As IHEStat.Implementation) As %Status
{
	Set tSC = $System.Status.OK()
	Set pObj = ""
	Try
	{
		Set oRS = ##class(%ResultSet).%New()
		Set tSC = oRS.Prepare("select %ID from IHEStat.Implementation where Vendor=? and Actor=? and Profile=?")
		Quit:$System.Status.IsError(tSC)
		
		Set tSC = oRS.Execute(pVendor.%Id(), pActor.%Id(), pProfile.%Id())
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

ClassMethod DeleteProfilesForVendor(pVendorId As %String) As %Status
{
	Set tSC = $System.Status.OK()
	Try
	{
		Set oRS = ##class(%ResultSet).%New()
		Set tSC = oRS.Prepare("delete from IHEStat.Implementation where Vendor=?")
		Quit:$System.Status.IsError(tSC)
		
		Set tSC = oRS.Execute(pVendorId)
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
<Data name="ImplementationDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Vendor</Value>
</Value>
<Value name="3">
<Value>Actor</Value>
</Value>
<Value name="4">
<Value>Profile</Value>
</Value>
</Data>
<DataLocation>^IHEStat.ImplementationD</DataLocation>
<DefaultData>ImplementationDefaultData</DefaultData>
<ExtentSize>100000</ExtentSize>
<IdLocation>^IHEStat.ImplementationD</IdLocation>
<IndexLocation>^IHEStat.ImplementationI</IndexLocation>
<StreamLocation>^IHEStat.ImplementationS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}
