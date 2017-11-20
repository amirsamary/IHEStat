Class IHEStat.Profile Extends (%Persistent, IHEStat.Base)
{

Relationship VendorImplementations As IHEStat.Implementation [ Cardinality = many, Inverse = Profile ];

Relationship SuccessfulTests As IHEStat.SuccessfulTest [ Cardinality = many, Inverse = Profile ];

Relationship Actors As IHEStat.Actor [ Cardinality = many, Inverse = Profile ];

Storage Default
{
<Data name="ProfileDefaultData">
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
<DataLocation>^IHEStat.ProfileD</DataLocation>
<DefaultData>ProfileDefaultData</DefaultData>
<IdLocation>^IHEStat.ProfileD</IdLocation>
<IndexLocation>^IHEStat.ProfileI</IndexLocation>
<StreamLocation>^IHEStat.ProfileS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}
