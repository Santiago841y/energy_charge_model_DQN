function this = MyEnvironment()
    % Initialize observation settings
    ObservationInfo = rlNumericSpec([4 1]);
    ObservationInfo.Name = 'CartPole States';
    ObservationInfo.Description = 'x, dx, theta, dtheta';

    % Initialize action settings   
    ActionInfo = rlFiniteSetSpec([-1 1]);
    ActionInfo.Name = 'CartPole Action';

    % The following line implements built-in functions of the RL environment
    this = this@rl.env.MATLABEnvironment(ObservationInfo,ActionInfo);

    % Initialize property values and precompute necessary values
    updateActionInfo(this);
end