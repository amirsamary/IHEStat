/// 
Class IHEStat.DS.SuccessfulTests Extends %DeepSee.CubeDefinition [ DependsOn = IHEStat.SuccessfulTest, ProcedureBlock ]
{

/// Cube definition from Architect.
XData Cube [ XMLNamespace = "http://www.intersystems.com/deepsee" ]
{
<cube xmlns="http://www.intersystems.com/deepsee" name="IHESuccessfulTests" displayName="IHE Successful Tests" disabled="false" abstract="false" sourceClass="IHEStat.SuccessfulTest" countMeasureName="%COUNT" bucketSize="8" bitmapChunkInMemory="false" precompute="0" disableListingGroups="false">
  <dimension name="Vendor" disabled="false" hasAll="false" allCaption="All Description" allDisplayName="Description" type="data" calendar="gregorian" iKnowType="entity" hidden="false" showHierarchies="default">
    <hierarchy name="H1" disabled="false" hidden="false">
      <level name="Vendor" disabled="false" sourceProperty="Vendor.Description" list="false" useDisplayValue="true" useAsFilter="true" hidden="false">
      </level>
    </hierarchy>
    <additionalDescription>undefined</additionalDescription>
  </dimension>
  <dimension name="Profile" disabled="false" hasAll="false" allCaption="All Description1" allDisplayName="Description1" type="data" calendar="gregorian" iKnowType="entity" hidden="false" showHierarchies="default">
    <hierarchy name="H1" disabled="false" hidden="false">
      <level name="Profile" disabled="false" sourceProperty="Profile.Code" list="false" useDisplayValue="true" useAsFilter="true" hidden="false">
      </level>
      <level name="Actor" disabled="false" sourceProperty="Actor.Code" list="false" useDisplayValue="true" useAsFilter="true" hidden="false">
      </level>
    </hierarchy>
    <additionalDescription>undefined</additionalDescription>
  </dimension>
  <dimension name="Connectathon" disabled="false" hasAll="false" allCaption="All Description" allDisplayName="Description" type="data" calendar="gregorian" iKnowType="entity" hidden="false" showHierarchies="default">
    <hierarchy name="H1" disabled="false" hidden="false">
      <level name="Connectathon" disabled="false" sourceProperty="Connectathon.Description" list="false" useDisplayValue="true" useAsFilter="true" hidden="false">
      </level>
    </hierarchy>
    <additionalDescription>undefined</additionalDescription>
  </dimension>
  <dimension name="ConnectathonYear" disabled="false" hasAll="false" allCaption="All ConnectathonYear" allDisplayName="ConnectathonYear" sourceProperty="Connectathon.ConnectathonYear" type="time" calendar="gregorian" hidden="false" showHierarchies="default">
    <hierarchy name="H1" disabled="false" hidden="false">
      <level name="ConnectathonYear" displayName="Year" disabled="false" timeFunction="Year" list="false" useDisplayValue="true" useAsFilter="true" hidden="false">
      </level>
    </hierarchy>
  </dimension>
  <measure name="Actors" disabled="false" sourceProperty="Actor.%ID" aggregate="COUNT" type="number" hidden="false" searchable="false">
  </measure>
  <measure name="Profiles" disabled="false" sourceProperty="Profile.%ID" aggregate="COUNT" type="number" hidden="false" searchable="false">
  </measure>
</cube>
}

Parameter DOMAIN;

}
