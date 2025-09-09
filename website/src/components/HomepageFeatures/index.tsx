import type {ReactNode} from 'react';
import clsx from 'clsx';
import useBaseUrl from '@docusaurus/useBaseUrl';
import Heading from '@theme/Heading';
import styles from './styles.module.css';

type FeatureItem = {
  title: string;
  Svg?: React.ComponentType<React.ComponentProps<'svg'>>;
  image?: string;
  description: ReactNode;
};

const FeatureList: FeatureItem[] = [
  {
    title: 'Siri Integration',
    image: '/img/siri.png',
    description: (
      <>
        Create custom voice commands for your Flutter app that work seamlessly with Siri.
        Enable users to interact with your app through natural voice commands.
      </>
    ),
  },
  {
    title: 'Shortcuts Support',
    image: '/img/shortcut.png',
    description: (
      <>
        Allow users to create custom shortcuts for your app&apos;s functionality.
        Integrate with iOS Shortcuts app and Spotlight search for enhanced discoverability.
      </>
    ),
  },
  {
    title: 'Type-Safe API',
    image: '/img/api.png',
    description: (
      <>
        Built with Flutter and Dart in mind, providing a strongly typed API
        with comprehensive error handling and modern async/await patterns.
      </>
    ),
  },
];

function Feature({title, Svg, image, description}: FeatureItem) {
  const imageUrl = useBaseUrl(image || '');
  return (
    <div className={clsx('col col--4')}>
      <div className="text--center">
        {Svg ? (
          <Svg className={styles.featureSvg} role="img" />
        ) : (
          <img src={imageUrl} className={styles.featureSvg} alt={title} />
        )}
      </div>
      <div className="text--center padding-horiz--md">
        <Heading as="h3">{title}</Heading>
        <p>{description}</p>
      </div>
    </div>
  );
}

export default function HomepageFeatures(): ReactNode {
  return (
    <section className={styles.features}>
      <div className="container">
        <div className="row">
          {FeatureList.map((props, idx) => (
            <Feature key={idx} {...props} />
          ))}
        </div>
      </div>
    </section>
  );
}
