% +MLFSL
%
% Files
%   AffineDirector                  - takes part in a builder design pattern for affine registration.
%   AlignmentBuilder                - 
%   AlignmentBuilderPrototype       - is a concrete prototpye;
%   AlignmentDirector               - is the concrete component in a decorator design pattern;
%   AlignmentDirectorComponent      - defines the interface for dynamically adding responsibilities
%   AlignmentDirectorDecorator      - DECORATEDALIGNMENTDIRECTOR maintains a reference to a component object,
%   ApplywarpOptions                - ...
%   BEOptionsAsl                    - BETASL ...
%   BEOptionsEpi                    - BETEPI ...
%   BEOptionsFlair                  - BETFLAIR ...
%   BEOptionsGre                    - BETGRE ...
%   BEOptionsT1                     - BETT1 ...
%   BEOptionsT2                     - BETT2 ...
%   BEOptionsTof                    - BETTOF ...
%   BetAsl                          - ...
%   BetBuilder                      - BETBUILDER
%   BetContext                      - BETSTRATEGY dispatches properties and methods to a chosen BetStrategy concrete class;
%   BetEpi                          - ...
%   BetFlair                        - ...
%   BetGre                          - ...
%   BetOptions                      - 
%   BetStrategy                     - Interface / Abstract Class
%   BetT1                           - ...
%   BetT2                           - ...
%   BetTof                          - ...
%   BrainExtractionOptions          - BETOPTIONS 
%   BrainExtractionOptionsInterface - 
%   BrainExtractionVisitor          - BETVISITOR   
%   ContrastRegistration            - is the abstract interface for a strategy design pattern:
%   ConvertXfmOptions               - CONVERTXFMOPTIONS
%   CoordinatedMake                 - coordinates other *Make classes 
%   DeprecatedImagingFeatures       - collects legacy data & behaviors of imaging-study objects
%   Downsampling                    - supports blurring and block-forming 
%   EpiRegistration                 - 
%   FastBuilder                     - is a facade and decorator design pattern for the segmentation tools of FSL
%   FastOptions                     - 
%   FastVisitor                     - 
%   FileAdapter                     - is a polymorphic adapter pattern for accessing files on the filesystem, especially NIfTI files 
%   FlirtBuilder                    - is a builder design pattern, delegates naming tasks to mlchoosers.ImagingChoosers, mlchoosers.ImagingParser
%   FlirtContext                    - provides the context of a strategy design pattern with FlirtStrategy,
%   FlirtedNIfTI                    - 
%   FlirtGauss                      - 
%   FlirtNoPreprocess               - FlirtNoPreprocess is a place-holder for FlirtStrategy for the case of no preprocessing
%   FlirtOptions                    - 
%   FlirtStrategy                   - FLIRTTYPE
%   FlirtSusan                      - 
%   FlirtVisitor                    - 
%   FnirtBuilder                    - is a builder design pattern
%   FnirtOptions                    - 
%   FnirtVisitor                    - 
%   FslBuilder                      - is DEPRECATED; prefer mlfsl.FslVisitor
%   FslContext                      - FSLSTRATEGY provides the baseclass context of a strategy design pattern with fsl-related strategies,
%   FslDataFactory                  - 
%   FslDirector                     - plays the role of director for a builder pattern that makes FSL-genereated products
%   FslDirectorInterface            - is the interface for directing all FSL-related builders that follow the GoF builder pattern
%   FslMathsVisitor                 - 
%   FslOptions                      - is the baseclass for options classes such as FlirtOptions, BetOptions, ...
%   FslProduct                      - provides data objects for processed images
%   FslRegistry                     - is a wrapper for simple database queries; is an mlpatterns.Singleton
%   FslStrategy                     - Interface / Abstract Class 
%   FslVisitor                      - 
%   FslVisitorInterface             - 
%   ICHemorrhage                    - ICHEMMORHAGE  
%   ICHemorrhageUnc                 - ICHEMMORHAGE  
%   ImageDirector                   - is the client interface that contains construction information.  Representation information should
%   ImageDirectorInterface          - is the interface for directing all image builders that follow the GoF builder pattern
%   InversewarpOptions              - INVERSEWARPOPTIONS
%   McflirtOptions                  - 
%   MocoVisitor                     - 
%   MorphingBuilder                 - 
%   MorphingDirector                - 
%   MRIBuilder                      - is a concrete builder for MRImagingComponent
%   MRIDirector                     - is the client wrapper for building MRI imaging analyses; 
%   NiftiDictionary                 - maps DICOM/IMA filenames to canonical names for NIfTI 
%   Np755Maker                      - makes the contents of the fsl-folder in the patient path
%   Np797Registry                   - is a wrapper for simple database queries;
%   Product                         - PRODUCTS provides data objects for processed images
%   ProductInterface                - provides data objects for processed images
%   SusanFacade                     - is a wrapper for the FSL Susan filtering schemes
