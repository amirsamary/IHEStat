/// 
Class IHEStat.DS.ImplementationCube Extends %DeepSee.CubeDefinition [ DependsOn = IHEStat.Implementation, ProcedureBlock ]
{

/// Cube definition from Architect.
XData Cube [ XMLNamespace = "http://www.intersystems.com/deepsee" ]
{
<cube xmlns="http://www.intersystems.com/deepsee" name="ImplementationCube" displayName="Implementation Cube" disabled="false" abstract="false" sourceClass="IHEStat.Implementation" countMeasureName="%COUNT" bucketSize="8" bitmapChunkInMemory="false" precompute="0" disableListingGroups="false">
  <dimension name="VendorDescription" disabled="false" hasAll="false" allCaption="All Description" allDisplayName="Description" type="data" hidden="false" showHierarchies="default">
    <hierarchy name="H1" disabled="false" hidden="false">
      <level name="VendorDescription" disabled="false" sourceProperty="Vendor.Description" list="false" nullReplacement="null" useDisplayValue="true" useAsFilter="true" hidden="false">
      </level>
    </hierarchy>
  </dimension>
  <dimension name="ProfileCode" disabled="false" hasAll="false" allCaption="All Description" allDisplayName="Description" type="data" iKnowType="entity" hidden="false" showHierarchies="default">
    <hierarchy name="H1" disabled="false" hidden="false">
      <level name="ProfileCode" displayName="Profile" disabled="false" sourceProperty="Profile.Code" list="false" nullReplacement="null" useDisplayValue="true" useAsFilter="true" hidden="false">
      </level>
    </hierarchy>
  </dimension>
  <dimension name="ActorCode" displayName="Actor" disabled="false" hasAll="false" allCaption="All Code" allDisplayName="Code" type="data" iKnowType="entity" hidden="false" showHierarchies="default">
    <hierarchy name="H1" disabled="false" hidden="false">
      <level name="ActorCode" displayName="Actor" disabled="false" sourceProperty="Actor.Code" list="false" nullReplacement="null" useDisplayValue="true" useAsFilter="true" hidden="false">
      </level>
    </hierarchy>
  </dimension>
  <measure name="ProfileCount" displayName="ProfileCount" description="ProfileCount" disabled="false" sourceProperty="Profile.%ID" aggregate="COUNT" type="number" hidden="false" searchable="true" iKnowSource="string">
  </measure>
  <measure name="CountOfVendors" displayName="CountOfVendors" description="Count of Vendors" disabled="false" sourceProperty="Vendor.%ID" aggregate="COUNT" type="number" hidden="false" searchable="true" iKnowSource="string">
  </measure>
  <listing name="Listado" disabled="false" listingType="table" fieldList="Vendor-&gt;Description " sql="select distinct Vendor-&gt;Description from $$$SOURCE where $$$RESTRICT">
  </listing>
</cube>
}

Parameter DOMAIN;

}
