{ArgumentError} = require 'lib/world/errors'

class Pacifies extends Component
  @className: 'Pacifies'

  attach: (thang) ->
    pacifyAction = name: 'pacify', cooldown: @cooldown, specificCooldown: @specificCooldown
    delete @cooldown
    delete @specificCooldown
    super thang
    thang.addActions pacifyAction
    thang.context = @getCodeContext?()
    @attackCount=0

  pacify: (target) ->
    unless target?
      throw new ArgumentError @contextPacifies?.error, "pacify", "target", "object", target
    @intent = 'pacify'
    @setTarget target, 'pacify'
    if @distance(@target, true) > @pacifyRange and @move
      @setAction 'move'
    else
      @setAction 'pacify'
    return @block()

  performPacify: (target) ->
    @sayWithoutBlocking?(@contextPacifies?.zap or 'Peace.')
    @target.say("I don't wanna fight anymore...")
    
    #Taste their own medicine. 
    #@target.takeDamage(@target.attackDamage/2)
    #TODO: Add new animation for this
    
    markName = 'electrocute'
    @target.effects = (e for e in @target.effects when e.name isnt markName)
    effects = [
      
      
      {name: markName, duration: @pacifyDuration, reverts: true, factor: @pacifyFactor, targetProperty: 'attackDamage'}
      
      {name: markName, duration: @pacifyDuration, reverts: true, factor: @pacifyFactor, targetProperty: 'maxSpeed'}
      {name: markName, duration: @pacifyDuration, reverts: true, factor: @pacifyFactor, targetProperty: 'actionTimeFactor'}
      {name: markName, duration: @pacifyDuration, reverts: true, factor: 0.8, targetProperty: 'maxHealth'}
    ]
    
    
    @target.addEffect effect, @ for effect in effects
    
    @pacifyComplete = true if @plan
    
    @unhide?() if @hidden
    
  
  blindedChooseAction: ->
    @setAction "idle"

  update: ->
    return unless @intent is 'pacify' and @isGrounded()
    if @action is 'move' and (@target? or @targetPos?)
      if @distance(@getTargetPos()) < @pacifyRange
        @setAction 'pacify'
    return unless @action is 'pacify' and @act()
    @performPacify()
    @rotation = Vector.subtract(@getTargetPos(), @pos).heading() if @getTargetPos()
    @unblock()
    
    @intent = undefined
    @setTarget null
    
    @setAction 'idle'

  canPacify: (target) ->
    if _.isString target
      target = @world.getThangByID target
    if target and not target.isThang and _.isString(target.id) and targetThang = @world.getThangByID target.id
      # Temporary workaround for Python API protection bug that makes them not Thangs
      target = targetThang
    unless target?.isThang
      throw new ArgumentError @contextPacify?.error1, "canCast", "target", "unit", target
    return false unless target.hasEffects
    return true
