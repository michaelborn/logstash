/**
* The base interceptor test case will use the 'interceptor' annotation as the instantiation path to the interceptor
* and then create it, prepare it for mocking, and then place it in the variables scope as 'interceptor'. It is your
* responsibility to update the interceptor annotation instantiation path.
*/
component extends="coldbox.system.testing.BaseTestCase"{

	/*********************************** LIFE CYCLE Methods ***********************************/
	this.loadColdbox = true;

	function beforeAll(){
		super.beforeAll();

		variables.interceptor = new logstash.interceptors.APISecurity();
		variable.interceptor = prepareMock( interceptor )
									.$( "getController", application.cbController );

		var moduleSettings = application.cbController.getSettingStructure().moduleSettings.logstash;
		variables.baseSettings = duplicate( application.cbController.getSettingStructure().moduleSettings.logstash );

	}

	function afterAll(){
		// do your own stuff here
		super.afterAll();
	}

	/*********************************** BDD SUITES ***********************************/

	function run(){

		describe( "logstash.interceptors.APISecurity", function(){

			beforeEach(function( currentSpec ){
				setup();
			});

			afterEach( function( currentSpec ){
				application.cbController.getSettingStructure().moduleSettings.logstash = variables.baseSettings;
			} );

			it( "Will override the event if the API is not enabled", function(){
				application.cbController.getSettingStructure().moduleSettings.logstash.enableAPI = false;

				var context=getRequestContext();

				interceptor.preEvent( context, {}, "", context.getCollection(), context.getCollection( private=true ) );

				expect( context.getCurrentEvent() ).toBe( "logstash:API.onInvalidHTTPMethod" );

			} );

			xit( "Will override the event if the Remote Host is not in the whitelist", function(){

			} );

			it( "Will override the event if the API token does not match", function(){
				application.cbController.getSettingStructure().moduleSettings.logstash.enableAPI = true;
				application.cbController.getSettingStructure().moduleSettings.logstash.apiAuthToken = createUUID();

				var context=getRequestContext();

				interceptor.preEvent( context, {}, "", context.getCollection(), context.getCollection( private=true ) );

				expect( context.getCurrentEvent() ).toBe( "logstash:API.onAuthenticationFailure" );
			} );

			it( "Will not change the event if allowed", function(){

				application.cbController.getSettingStructure().moduleSettings.logstash.enableAPI = true;
				application.cbController.getSettingStructure().moduleSettings.logstash.apiAuthToken = "";

				var context=getRequestContext();

				var originalEvent = context.getCurrentEvent();

				interceptor.preEvent( context, {}, "", context.getCollection(), context.getCollection( private=true ) );

				expect( context.getCurrentEvent() ).toBe( originalEvent );

			} );


		});

	}

}
