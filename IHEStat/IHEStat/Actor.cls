Class IHEStat.Actor Extends (%Persistent, IHEStat.Base)
{

Relationship Profile As IHEStat.Profile [ Cardinality = one, Inverse = Actors ];

Index ProfileIndex On Profile;

Relationship Participations As IHEStat.Implementation [ Cardinality = many, Inverse = Actor ];

Relationship SuccessfulTests As IHEStat.SuccessfulTest [ Cardinality = many, Inverse = Actor ];

ClassMethod OpenByDescription(pDescription As %String, Output pObj As %Persistent = "") As %Status
{
	Set tSC = $System.Status.OK()
	Try
	{
		Set oRS = ##class(%ResultSet).%New()
		
		// This works because the classes are all one package deep:
		Set tSC = oRS.Prepare("select %ID from "_..%ClassName(1)_" where Description %startswith ?")
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
<Data name="ActorDefaultData">
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
<Value>Profile</Value>
</Value>
</Data>
<DataLocation>^IHEStat.ActorD</DataLocation>
<DefaultData>ActorDefaultData</DefaultData>
<ExtentSize>100000</ExtentSize>
<IdLocation>^IHEStat.ActorD</IdLocation>
<IndexLocation>^IHEStat.ActorI</IndexLocation>
<StreamLocation>^IHEStat.ActorS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}
