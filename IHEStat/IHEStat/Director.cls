/// <p>Written by Amir Samary, Senior Sales Engineer</p>
/// <p>This tool "screen scrapes” IHE’s connect-a-thon results web site and downloads all the results into Caché tables to populate a cube that you can use to know which company implemented which IHE profile for which Actors.</p>
/// <p>Load this Caché project into any DeepSee enabled namespace and run the following command:</p>
/// <pre>
/// 	USER> Set tSC = ##class(IHEStat.Director).DownloadAll()
/// 	USER> Write tSC
/// 	1
/// </pre>
/// <p>The command will start dozens of Jobs to parallelize the downloading of data from IHE’s web site (it has a lot of latency so parallelizing it really really helps a lot). It should just take a couple of minutes. If you want to know what it is doing, look into global ^IHEStat on another Terminal session.</p>
/// <p>After the command is finished, build the cube IHEStat.DS.ImplementationCube and use it to explore IHE connect-a-thon results.</p>
/// <p>Enjoy!</p>
Class IHEStat.Director Extends %RegisteredObject
{

Parameter MAINURL = "connectathon-results.ihe.net";

Parameter SELECTOPTIONPATTERN = "(?is).*?<option +value *= *""(.*?)"" *>(.*?)</option>";

Parameter FORMPATTERN = "(?is).*?<FORM +NAME *= *""(.*?)"" +ACTION *= *""(.*?)"".*";

Parameter TABLETAGS = "(?is)(<TR.*?>)?.*?(<TH.*?>.*?|<TD.*?>.*?)?(</TD>|</TH>|</TR>).*?";

ClassMethod Test()
{
	Try
	{
		s t="<TR><TD rowspan=1 colspan=1></TD><TH colspan = 1 onmouseover=""return overlib('<b>Patient Demographic Query HL7 V3</b>:<br>This profile provides ways for multiple distributed applications to query a central patient information server for a list of patients, based on user-defined search criteria. Patient demographics data can be entered directly into the application from which the user is querying by picking the appropriate record from a list of possible matches (called here a patient pick list).');"" onmouseout=""return nd();"">Patient Demographic Query HL7 V3</TH>"
		Set oPattern = ##class(%Regex.Matcher).%New(..#TABLETAGS)
		Set oPattern.Text=t
		
		While oPattern.Locate()
		{
			Write !,"Start: ",oPattern.Start
			Write !,"End: ",oPattern.End
			
		
			For i=1:1:oPattern.GroupCount
			{
	
				Write !!,"Group ",i,": ",oPattern.Group(i),!!
			}
		
			//Do $System.OBJ.Dump(oPattern)
		}
	}
	Catch (tException)
	{
		d $System.OBJ.Dump(tException)
		
		Write tException.DisplayString()
	}
}

ClassMethod GetSSLConfigurationName(Output pSC As %Status) As %String
{
	Set pSC = $System.Status.OK()
	Set tSSLConfigName="IHE"
	Set tNS = $Namespace
	Try
	{
		zn "%SYS"
		
		Quit:##class(Security.SSLConfigs).Exists(tSSLConfigName)
		
		Set Properties=""
		Set Properties("Protocols")=31
		Set Properties("Enabled")=1
		Set pSC = ##class(Security.SSLConfigs).Create(tSSLConfigName,.Properties)
	}
	Catch (oException)
	{
		Set pSC =oException.AsStatus()
		Set tSSLConfigName=""
	}
	
	Set $Namespace = tNS
	
	Quit tSSLConfigName
}

ClassMethod DownloadAll() As %Status
{
	Set tSC = $System.Status.OK()
	Try
	{
		If $Get(^IHEStat("Status"))="Running"
		{
			Write !,"IHE Stat already running!"
			Quit
		}
		
		Set tSC = ##class(IHEStat.Implementation).%DeleteExtent()
		Quit:$System.Status.IsError(tSC)
		Set tSC = ##class(IHEStat.SuccessfulTest).%DeleteExtent()
		Quit:$System.Status.IsError(tSC)
		Set tSC = ##class(IHEStat.Actor).%DeleteExtent()
		Quit:$System.Status.IsError(tSC)
		Set tSC = ##class(IHEStat.Profile).%DeleteExtent()
		Quit:$System.Status.IsError(tSC)
		Set tSC = ##class(IHEStat.Connectathon).%DeleteExtent()
		Quit:$System.Status.IsError(tSC)
		Set tSC = ##class(IHEStat.Vendor).%DeleteExtent()
		Quit:$System.Status.IsError(tSC)
		
		Kill ^IHEStat
		Set ^IHEStat("Status")="Running"
		
		Set oResponseStream = ##class(%Stream.GlobalCharacter).%New()
		
		Set oHTTPRequest=##class(%Net.HttpRequest).%New()
		Set oHTTPRequest.Server=..#MAINURL
		Set oHTTPRequest.Https=1
		Set oHTTPRequest.SSLConfiguration=..GetSSLConfigurationName(.tSC)
		Quit:$System.Status.IsError(tSC)
		Set oHTTPRequest.ResponseStream = oResponseStream
		Set tSC = oHTTPRequest.Get("/index.php")
		Quit:$System.Status.IsError(tSC)
		
		//Do oHTTPRequest.HttpResponse.OutputToDevice()
		
		Set oPatternForm = ##class(%Regex.Matcher).%New(..#FORMPATTERN)
		Set oPatternSelectOption = ##class(%Regex.Matcher).%New(..#SELECTOPTIONPATTERN)
		
		Set oResponseStream.LineTerminator=$C(10)
		
		//
		//FIRST, lest download the companies and their current implementation of profiles. 
		//This will create all companies and profiles with proper code and descriptions.
		//
		
		Do oResponseStream.Rewind()
		
		Set tForm = ""
		//Set tAction = ""
		While 'oResponseStream.AtEnd
		{
			Set tLine = oResponseStream.ReadLine()
			Continue:tLine=""
			
			Set tLowerCaseLine = $ZConvert(tLine,"L")
			
			If tLowerCaseLine["<form"
			{
				If oPatternForm.Match(tLine)
				{
					If oPatternForm.GroupCount=2
					{
						Set tForm = oPatternForm.Group(1)
						//Set tAction = oPatternForm.Group(2)
						Continue
					}
				}
			}
			
			Continue:tForm=""
			
			Set oPatternSelectOption.Text=tLine
			Do oPatternSelectOption.ResetPosition()
			
			While oPatternSelectOption.Locate()
			{
				Set tCode = oPatternSelectOption.Group(1)
				Continue:tCode="none"
				
				Set tDesc = oPatternSelectOption.Group(2)
				
				If tForm="company"
				{
					While $Get(^IHEStat("Jobs"),0)>10
					{
						Hang 1
					}
					
					Write !,"Starting job for company with code """,tCode,"""..."
					Set tCode=$ZStrip($ZConvert(tCode,"U"),"<>WP")
					Set tSC = ##class(IHEStat.Vendor).CreateOrUpdate(tCode, tDesc, .oVendor)
					Quit:$System.Status.IsError(tSC)
					
					Job ..DownloadProfilesForVendor(oVendor.%Id())
				}
			}
			Quit:$System.Status.IsError(tSC)
		}
		Quit:$System.Status.IsError(tSC)

		Set tSC = ..Join()
		Quit:$System.Status.IsError(tSC)

		//
		//NOW, Let's download data from each connect-a-thon
		//
		
		Do oResponseStream.Rewind()
		
		Set tForm = ""
		//Set tAction = ""
		While 'oResponseStream.AtEnd
		{
			Set tLine = oResponseStream.ReadLine()
			Continue:tLine=""
			
			Set tLowerCaseLine = $ZConvert(tLine,"L")
			
			If tLowerCaseLine["<form"
			{
				If oPatternForm.Match(tLine)
				{
					If oPatternForm.GroupCount=2
					{
						Set tForm = oPatternForm.Group(1)
						//Set tAction = oPatternForm.Group(2)
						Continue
					}
				}
			}
			
			Continue:tForm=""
			
			Set oPatternSelectOption.Text=tLine
			Do oPatternSelectOption.ResetPosition()
			
			While oPatternSelectOption.Locate()
			{
				Set tCode = oPatternSelectOption.Group(1)
				Continue:tCode="none"
				
				Set tDesc = oPatternSelectOption.Group(2)
				
				If tForm="connectathon"
				{
					//Set tCode=$ZStrip(tCode,"<>W")
					Continue:tCode="" //All Connectathon
					//Continue:$Extract(tCode,1,3)'="EYE"
					Write !,tCode," - ",tDesc
					
					Set tSC = ##class(IHEStat.Connectathon).CreateOrUpdate(tCode, tDesc, .oConnectathon)
					Quit:$System.Status.IsError(tSC)
					
					Set tSC = ..DownloadTestsForConnectathon(oConnectathon.%Id())
					Quit:$System.Status.IsError(tSC)
				}
			}
			Quit:$System.Status.IsError(tSC)
		}
		Quit:$System.Status.IsError(tSC)

		
		Set tSC = ..Join()
		Quit:$System.Status.IsError(tSC)
	}
	Catch (oException)
	{
		If oException.Name'="<INTERRUPT>"
		{
			If oException.%IsA("%Exception.SystemException")
			{
			    Set $zerror = oException.DisplayString()
			}

			Set tSC = oException.AsStatus()
			
			Do LOG^%ETN
		}
	}
	
	Set ^IHEStat("Status")="Done"
	
	If $System.Status.IsError(tSC)
	{
		Set ^IHEStat("ErrorStatus")=$System.Status.GetErrorText(tSC)
	}
	Else
	{
		Set ^IHEStat("ErrorStatus")=1
		
		Set tSC = $System.DeepSee.BuildCube("IHESuccessfulTests")
		Quit:$System.Status.IsError(tSC)
		
		Set tSC = $System.DeepSee.BuildCube("ImplementationCube")
		Quit:$System.Status.IsError(tSC)
		
	}
	
	Quit tSC
}

ClassMethod DownloadProfilesForVendor(pVendorId As %String) As %Status
{
	Set tSC = $System.Status.OK()
	Try
	{
		Set dummy=$Increment(^IHEStat("Jobs"))
		
		Set oVendor = ##class(IHEStat.Vendor).%OpenId(pVendorId)
		
		Do
		{
			Set ^IHEStat("Job",$Job)="Running"
			
			Set tSC = ##class(IHEStat.Implementation).DeleteProfilesForVendor(pVendorId)
			Quit:$System.Status.IsError(tSC)
			
			Set oResponseStream = ##class(%Stream.GlobalCharacter).%New()
		
			Set oHTTPRequest=##class(%Net.HttpRequest).%New()
			Set oHTTPRequest.Server=..#MAINURL
			Set oHTTPRequest.Https=1
			Set oHTTPRequest.SSLConfiguration=..GetSSLConfigurationName(.tSC)
			Quit:$System.Status.IsError(tSC)
			Set oHTTPRequest.ResponseStream = oResponseStream
			Set oResponseStream.LineTerminator=$C(10)
			Do oHTTPRequest.InsertFormData("company", oVendor.Code)
			Set tSC = oHTTPRequest.Post("/view_result.php?rows=actor&columns=integration_profile&title=company")
			If $System.Status.GetErrorCodes(tSC)["5922" 
			{
				Set tSC = $System.Status.OK()
				Continue //Try again if a timeout ocurred
			}
			Quit //If I am here, it's because we did it or we got an error different from timeout
		}
		While 1
		Quit:$System.Status.IsError(tSC)
		
		//Do oResponseStream.OutputToDevice()
		Do oResponseStream.Rewind()
		
		Set oPatternTableTags= ##class(%Regex.Matcher).%New(..#TABLETAGS)
		
		Set iLine=0
		Set tNotRecog=""
		Set bMatchedFirstTR = 0
		While 'oResponseStream.AtEnd
		{
			Set oPatternTableTags.Text=tNotRecog_oResponseStream.ReadLine()
			Set tNotRecog=""
			
			Quit:oPatternTableTags.Text["</TABLE>"
			
			Do oPatternTableTags.ResetPosition()
			
			//Write !,$E(oPatternTableTags.Text,1,70)
			Set bMatched=0
			While oPatternTableTags.Locate()
			{
				Set bMatched=1
				
				//Write !,oPatternTableTags.Group(1)
				
				Set bIsTR = ($Extract($ZConvert(oPatternTableTags.Group(1),"L"),1,3)="<tr")
				Set tData=oPatternTableTags.Group(2)
				
				Set bIsTH = ($Extract($ZConvert(tData,"L"),1,3)="<th")
								
				If bIsTR
				{
					Set iLine=iLine+1
					Set iCol=0
					Set oCurrentActor=""
					Set bMatchedFirstTR = 1
					
					//Write !,"bIsTR:",bIsTR," - bIsTH: ",bIsTH," - iLine: ",iLine
				}
				
				If (iLine=1) && (bIsTH)
				{
					Set iCol=iCol+1
					
					Set tProfileName=$Piece($Piece(tData,"<b>",2),"</b>",1)
					Set tProfileDesc=$Piece($Piece(tData,"<br>",2),"')",1)
					Set tProfileDesc=$Replace(tProfileDesc,"<center>","")
					Set tProfileDesc=$Replace(tProfileDesc,"</center>","")
					If tProfileDesc="" Set tProfileDesc=tProfileName
					
					Set tSC = ##class(IHEStat.Profile).CreateOrUpdate(tProfileName, tProfileDesc, .oProfile)
					Quit:$System.Status.IsError(tSC)
					
					Write !,iCol," - ",tProfileName," - ",tSC
					Set vProfiles(iCol)=oProfile
					Set oProfile=""
					
				}
				ElseIf (iLine=1) && ('bIsTH)
				{
					//Ignore
				}
				ElseIf (iLine>1) && (bIsTH)
				{
					Set tActorName=$Piece($Piece(tData,"<b>",2),"</b>",1)
					
					Set tSC = ##class(IHEStat.Actor).CreateOrUpdate(tActorName, tActorName, .oCurrentActor)
					Quit:$System.Status.IsError(tSC)
				}
				ElseIf (iLine>1) && ('bIsTH)
				{
					Set iCol=iCol+1
					Set bImplements = ($Piece($Piece(tData,";"">",2),"&nbsp;")="*")
					
					//Write !,tData,!!
					
					If bImplements
					{
						Set tSC = ##class(IHEStat.Implementation).CreateOrUpdate(oVendor, oCurrentActor, vProfiles(iCol), .oImplementation)
						Quit:$System.Status.IsError(tSC)
					}
				}
			}
			Quit:$System.Status.IsError(tSC)
			
			If (bMatchedFirstTR) && ('bMatched)
			{
				Set tNotRecog=oPatternTableTags.Text
			}
		}
		
	}
	Catch (oException)
	{
		If oException.Name="<INTERRUPT>" Throw oException
		
		If oException.%IsA("%Exception.SystemException")
		{
		    Set $zerror = oException.DisplayString()
		}

		Set tSC = oException.AsStatus()
		
		Do LOG^%ETN
	}
	
	Set ^IHEStat("Job",$Job)=1
	
	If $System.Status.IsError(tSC)
	{
		//Do $System.Status.DisplayError(tSC)
		Set ^IHEStat("Job",$Job)=tSC
		Set ^IHEStat("Job",$Job,"Vendor")=pVendorId
	}
	
	Set dummy=$Increment(^IHEStat("Jobs"),-1)
	
	Quit tSC
}

ClassMethod DownloadTestsForConnectathon(pConnectathonId As %String) As %Status
{
	Set tSC = $System.Status.OK()
	Try
	{
		Set oConnectathon = ##class(IHEStat.Connectathon).%OpenId(pConnectathonId)
		
		Do
		{
			Set ^IHEStat("Job",$Job)="Running"
			
			Set tSC = ##class(IHEStat.SuccessfulTest).DeleteTestsForConnectathon(pConnectathonId)
			Quit:$System.Status.IsError(tSC)
			
			Set oResponseStream = ##class(%Stream.GlobalCharacter).%New()
		
			Set oHTTPRequest=##class(%Net.HttpRequest).%New()
			Set oHTTPRequest.Server=..#MAINURL
			Set oHTTPRequest.Https=1
			Set oHTTPRequest.SSLConfiguration=..GetSSLConfigurationName(.tSC)
			Quit:$System.Status.IsError(tSC)
			Set oHTTPRequest.ResponseStream = oResponseStream
			Set oResponseStream.LineTerminator=$C(10)
			Do oHTTPRequest.InsertFormData("connectathon", oConnectathon.Code)
			Set tSC = oHTTPRequest.Post("view_result.php?rows=company&columns=integration_profile&subcolumns=actor&title=connectathon")
			If $System.Status.GetErrorCodes(tSC)["5922" 
			{
				Set tSC = $System.Status.OK()
				Hang 1
				Continue //Try again if a timeout ocurred
			}
			Quit //If I am here, it's because we did it or we got an error different from timeout
		}
		While 1
		Quit:$System.Status.IsError(tSC)
		
		//Do oResponseStream.OutputToDevice()
		Do oResponseStream.Rewind()
		
		Set oPatternTableTags= ##class(%Regex.Matcher).%New(..#TABLETAGS)
		
		Set iLine=0
		Set tNotRecog=""
		Set bMatchedFirstTR = 0
		While 'oResponseStream.AtEnd
		{
			Set oPatternTableTags.Text=tNotRecog_oResponseStream.ReadLine()
			Set tNotRecog=""
			
			Quit:oPatternTableTags.Text["</TABLE>"
			
			Do oPatternTableTags.ResetPosition()
			
			//Write !,$E(oPatternTableTags.Text,1,70)
			Set bMatched=0
			While oPatternTableTags.Locate()
			{
				Set bMatched=1
				
				//Write !,oPatternTableTags.Group(1)
				
				Set bIsTR = ($Extract($ZConvert(oPatternTableTags.Group(1),"L"),1,3)="<tr")
				Set tData=oPatternTableTags.Group(2)
				
				Set bIsTH = ($Extract($ZConvert(tData,"L"),1,3)="<th")
								
				If bIsTR
				{
					Set iLine=iLine+1
					Set iCol=0
					//Set oCurrentActor=""
					Set oCurrentVendor=""
					Set bMatchedFirstTR = 1
					
					//Write !,"bIsTR:",bIsTR," - bIsTH: ",bIsTH," - iLine: ",iLine
				}
				
				If (iLine=1) && (bIsTH)
				{
					Set iCol=iCol+1
					/*	
					Set tProfileName=$Piece($Piece(tData,"<b>",2),"</b>",1)
					
					Set tSC = ##class(IHEStat.Profile).OpenByCode(tProfileName, .oProfile)
					Quit:$System.Status.IsError(tSC)
					
					Set vProfiles(iCol)=oProfile
					Set oProfile=""
					*/			
				}
				ElseIf (iLine=1) && ('bIsTH)
				{
					//Ignore
				}
				ElseIf (iLine=2)
				{
					//Actors
					Set iCol=iCol+1
					
					Set tActorName=$ZStrip($Piece($Piece(tData,"<b>",2),"</b>",1),"<>W")
					Continue:tActorName=""
					
					Set tSC = ##class(IHEStat.Actor).OpenByCode(tActorName, .oActor)
					Quit:$System.Status.IsError(tSC)
					
					If oActor=""
					{
						Set tSC = ##class(IHEStat.Actor).CreateOrUpdate(tActorName, tActorName, .oActor)
						Quit:$System.Status.IsError(tSC)
						
						Set tSC = ##class(IHEStat.Profile).CreateOrUpdate("%UKNPRF", "Unknown Profile", .oProfile)
						Quit:$System.Status.IsError(tSC)
						
						If oActor.Profile=""
						{
							Set oActor.Profile=oProfile
							Set tSC = oActor.%Save()
							Quit:$System.Status.IsError(tSC)
						}
					}
					
					Set vActors(iCol+1)=oActor
					Set oActor=""							
				}
				ElseIf (iLine>2) && (bIsTH)
				{
					Continue:tData["<th align=""left"">&nbsp;" //not counting this as a column
					
					Set iCol=iCol+1
					
					Set tVendorName=$ZStrip($Piece(tData,"<TH>",2),"<>W")
					Write !,tVendorName
					
					Set tSC = ##class(IHEStat.Vendor).OpenByDescription(tVendorName, .oCurrentVendor)
					Quit:$System.Status.IsError(tSC)
					
					If oCurrentVendor=""
					{
						Set tSC = ##class(IHEStat.Vendor).CreateOrUpdate(tVendorName, tVendorName, .oCurrentVendor)
						Quit:$System.Status.IsError(tSC)
					}
				}
				ElseIf (iLine>2) && ('bIsTH)
				{
					Set iCol=iCol+1
					Set bTestedSuccessfuly = ($Piece($Piece(tData,";"">",2),"&nbsp;")="*")
					
					//Write !,tData,!!
					
					If bTestedSuccessfuly
					{
						Set oCurrentActor = vActors(iCol)
																		
						Set tSC = ##class(IHEStat.SuccessfulTest).CreateOrUpdate(oConnectathon, oCurrentVendor, oCurrentActor, oCurrentActor.Profile, .oImplementation)
						Quit:$System.Status.IsError(tSC)
					}
				}
			}
			Quit:$System.Status.IsError(tSC)
			
			If (bMatchedFirstTR) && ('bMatched)
			{
				Set tNotRecog=oPatternTableTags.Text
			}
		}
		
	}
	Catch (oException)
	{
		If oException.Name="<INTERRUPT>" Throw oException
		
		If oException.%IsA("%Exception.SystemException")
		{
		    Set $zerror = oException.DisplayString()
		}

		Set tSC = oException.AsStatus()
		
		Do LOG^%ETN
	}
	
	Set ^IHEStat("Job",$Job)=1	
	
	If $System.Status.IsError(tSC)
	{
		//Do $System.Status.DisplayError(tSC)
		Set ^IHEStat("Job",$Job)=tSC
		Set ^IHEStat("Job",$Job,"Connectathon")=pConnectathonId
		Merge ^IHEStat("Job",$Job,"Actors")=vActors
	}
	
	Quit tSC
}

ClassMethod Join() As %Status
{
	Set tSC = $System.Status.OK()
	
	Set bRunning=1
	
	While bRunning
	{
		Hang 1
		Set tJob=""
		Set bDone=1
		Set tSC = $System.Status.OK()
		For
		{
			Set tJob = $Order(^IHEStat("Job",tJob))
			Quit:tJob=""
			
			If ^IHEStat("Job",tJob)="Running"
			{
				Set bDone=0
				Quit
			}
			
			Set tSC = $System.Status.AppendStatus(tSC, ^IHEStat("Job",tJob))
		}
		
		Set bRunning='bDone
	}
	
	Quit tSC
}

}
