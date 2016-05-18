Current Work:
... let's use this space to lay out the features we are building.

Onboarding Flow
Look and feel: Let's back these views with beautiful landscapes. 

START: (in AppDelegate or MessageStreamViewController) Check whether location permissions have been granted. 
    If granted, -> (SYNC). 
    If unknown, request permissions -> (SYNC).
    If denied, prompt to change settings -> (SYNC)
SYNC: Check for a saved profile.
    If exists, check for partner. 
        If partner -> (LAUNCH)
        If no partner -> (PAIR)
    If no profile, create a new profile and save it. -> (PAIR)
        
PAIR: Show a view with the profile's pair code and a text field to submit a partner's pair code. Link to text your partner.
    Check periodically for a partner code. 
        If paired -> (LAUNCH)
    When a code is entered
        If successful pairing -> (LAUNCH)
LAUNCH: Load MessageStreamView. 
