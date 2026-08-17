class_name JumpItem
extends Item
## Test item: makes the actor jump when used.
## Not consumed — treated as a reusable "ability" item rather than
## a one-shot potion. Flip `use()` to `return true` if you want it
## to disappear after one use instead.

func use(actor: Node) -> bool:
	if actor == null or not actor.has_method("jump"):
		push_warning("JumpItem used on an actor without jump(): %s" % display_name)
		return false
	actor.jump()
	return false  # stays in inventory