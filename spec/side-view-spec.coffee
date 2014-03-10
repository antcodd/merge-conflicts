{$} = require 'atom'
SideView = require '../lib/side-view'
Conflict = require '../lib/conflict'
util = require './util'

describe 'SideView', ->
  [view, editorView, ours, theirs] = []

  text = -> editorView.getEditor().getText()

  beforeEach ->
    editorView = util.openPath("single-2way-diff.txt")
    conflict = Conflict.all(editorView.getEditor())[0]
    [ours, theirs] = [conflict.ours, conflict.theirs]
    view = new SideView(ours, editorView)

  it 'identifies its lines in the editor', ->
    linetext = $(line).text() for line in view.lines()
    expect(linetext).toEqual("These are my changes")

  it 'identifies the ref banner line', ->
    linetext = view.refBannerLine().text()
    expect(linetext).toBe('<<<<<<< HEAD')

  it 'positions itself over the banner line', ->
    expect(view.offset().top).toEqual(view.refBannerOffset().top)
    expect(view.height()).toEqual(view.refBannerLine().height())

  it 'triggers conflict resolution', ->
    spyOn(ours, "resolve")
    view.useMe()
    expect(ours.resolve).toHaveBeenCalled()

  describe 'when chosen as the resolution', ->

    beforeEach ->
      ours.resolve()

    it 'adds the "resolved" class', ->
      classes = line.className.split /\s+/ for line in view.lines()
      expect(classes).toContain("resolved")
      expect(classes).toContain("conflict-line")
      expect(classes).not.toContain("ours")
      expect(classes).not.toContain("theirs")

    it 'deletes the marker line', ->
      expect(text()).not.toContain("<<<<<<< HEAD")

  describe 'when not chosen as the resolution', ->

    beforeEach ->
      theirs.resolve()

    it 'deletes its lines', ->
      expect(text()).not.toContain("These are my changes")

    it 'deletes the marker line', ->
      expect(text()).not.toContain("<<<<<<< HEAD")
