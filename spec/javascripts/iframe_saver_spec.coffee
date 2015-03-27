success_response =
  status: 200,
  responseText: '{}'

# this spec is very out of date with the current code
describe 'IFrameSaver', () ->
  fake_phone          = null
  saver               = null
  request             = null

  fake_phone          = jasmine.createSpyObj('iframePhone',['post','addListener'])
  fake_save_indicator = jasmine.createSpyObj('SaveIndicator',['showSaved','showSaving', 'showSaveFailed'])

  beforeEach () ->
    window.iframePhone.ParentEndpoint = () ->
      return fake_phone
    loadFixtures "iframe-saver.html"

  describe "with an interactive in in iframe", ->
    beforeEach () ->
      # jasmine.Ajax.install();
      saver = new IFrameSaver($('#interactive'),$('#interactive_data_div'),$('.delete_interactive_data'))
      saver.save_indicator = fake_save_indicator

    afterEach () ->
      # jasmine.Ajax.uninstall();

    describe "a sane testing environment", () ->
      it 'has an instance of IFrameSaver defined', () ->
        expect(saver).toBeDefined()

      it 'has an iframe to work with', () ->
        expect($("#interactive")[0]).toExist()

      it 'has an interactive data element', () ->
        expect($("#interactive_data_div")).toExist()

    describe "constructor called in the correct context", () ->
      it "should have a put url", () ->
        expect(saver.put_url).toBe("foo/42")
      it "should have a get url", () ->
        expect(saver.get_url).toBe("bar/42")
    describe "save", () ->
      beforeEach () ->
        saver.save()

      it "invokes the correct message on the iframePhone", () ->
        expect(fake_phone.post).toHaveBeenCalledWith({ type:'getInteractiveState' });

    describe "save_to_server", () ->
      beforeEach () ->
        jasmine.Ajax.install()
        saver.save_to_server({foo:'bar'})
        request = jasmine.Ajax.requests.mostRecent()
        request.respondWith(success_response)

      afterEach () ->
        jasmine.Ajax.uninstall()

      describe "a successful save", () ->
        it "should display the show saved indicator", () ->
          # TODO: Ran out of time writing this test...
          # waits 2000
          # runs ->
          #   expect(fake_save_indicator.showSaving).toHaveBeenCalled()
          #   expect(fake_save_indicator.showSaved).toHaveBeenCalled()

