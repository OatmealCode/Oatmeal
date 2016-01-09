import Foundation

public class FileLog : NSObject,Loggable
{
    public var location : String
    public var config : Configuration?
    
    public static var entityName : String? = "FileLog"
    public var time : String
    public var type : LogType
    
	public required override init()
	{
        let formatter         = NSDateFormatter()
        formatter.dateStyle   = NSDateFormatterStyle.FullStyle
        let currentTime       = NSDate()
        self.time             = formatter.stringFromDate(currentTime)
        self.type             = .Success
        self.location         = "App"
        super.init()
	}

	public func write(message:String)
	{
        if let config : Configuration = ~Oats()
        {
            self.config = config
        }
        
        guard let logLocation = self.config?.get("LOG_LOCATION") as? String else
        {
            print("LOG_LOCATION NOT SET!")
            return
        }
        
        self.location     = logLocation
        
        print("The log is \(config!.get("LOG_ENABLED"))")
        
        //If file log is disabled we won't try to write to it.
        if let config = self.config, logEnabled = config.get("LOG_ENABLED") as? Bool where logEnabled == false
        {
            print(logEnabled)
            return
        }
        let url = NSURL(fileURLWithPath: self.location)
        do{
            let log = try NSFileHandle(forUpdatingURL: url)
        
            if let oldText = NSString(data: log.readDataToEndOfFile(), encoding: NSUTF8StringEncoding)
            {
                let currentLog   = "\(oldText)[Time: \(time), Type: \(self.type)]: \(message)\n"
                let absolutePath = NSURL(fileURLWithPath: self.location)
                let fileHandle   = NSFileHandle(forWritingAtPath: absolutePath.path!)
                fileHandle?.writeData(currentLog.dataUsingEncoding(NSUTF8StringEncoding)!)
            }
        }
        catch(let error)
        {
            print(error)
            print("If the log is currently not working, please check your Settings.Plist file and make sure LOG_LOCATION is set correctly.")
        }
	}
    
    public func success(message:String)
    {
        self.type = .Success
        self.write(message)
    }

    public func success<T:AnyObject>(message:[T])
	{
        self.type = .Success
        self.write(self.fromArray(message))
	}

	public func error(message:String)
	{
        self.type  = .Warning
        self.write(message)
	}

    public func error<T:AnyObject>(message:[T])
	{
        self.type  = .Warning
        write(fromArray(message))
	}
    
    func fromArray<T:AnyObject>(message:[T])->String
    {
        var messageToWrite = "[\(time)]:"
        
        for i in message
        {
            messageToWrite += String(i)
        }
        return messageToWrite
    }
    

    public func didBind()
    {
       
    }
    
    /*
       By the off chance Configuration isn't bound to the Container we will bind it to prevent a crash.
    */
    public func didResolve()
    {
        Oats().bindIf({!Oats().has("Configuration")},
            withMember : Configuration.self,
            completion : {}
        )
    }
}

